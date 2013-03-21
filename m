From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [BUG NFQUEUE] NFQUEUE readers get -PERM from sys_sendto() if !root
Date: Thu, 21 Mar 2013 15:36:43 +0100
Message-ID: <20130321143643.GH13505@imap.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

after updating to kernel v3.8.4 I see that Netfilter NFQUEUE readers
get -EPERM from sys_sendto() at the time they try to inject the verdict
back to the kernel.  This only occurs iff not running as 'root'.

The last working kernel is v3.7.7.

Skimming through the changeset since v3.7.7 the following changes
pop up:

 userns: Require CAP_SYS_ADMIN for most uses of setns.
 userns: Allow unprivileged use of setns.

So it could be related to my current namespace config, which is

  CONFIG_NAMESPACES=y
  # CONFIG_UTS_NS is not set
  # CONFIG_IPC_NS is not set
  # CONFIG_USER_NS is not set
  # CONFIG_PID_NS is not set
  # CONFIG_NET_NS is not set

I rate this a major issue, as quite some of those programs
drop privileges for various reasons.

Is this a known issue?  Well, I skimmed through the list, but didn't
find anything.

 /Holger

