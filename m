From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [RFC][0/2] remove atm_find_ci(); convert vcc_sklist to hash
Date: Wed, 08 Oct 2003 08:46:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310081246.h98CkPkT028970@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

the following two patches (which should be applied to a current 2.6 tree)
obseletes atm_find_ci() which races the vpi/vci allocation (since the 
actual allocation is delayed until after the entering the drivers open()
routine).  all drivers now use the built-in find_ci().  to address
performance issues the second patch converts the vcc_sklist to a hash
based on the lower 5 bits in the vci.  should this be tunable via config?
for most users (< 100 vccs) this should be fairly efficient.  on a side
note, signalling/ilmi/control vccs are all in bucket 0.  the control
vccs probably should be given a non-zero vci to make this 'better'.
