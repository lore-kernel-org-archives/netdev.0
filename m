From: Peter Bieringer <pb@bieringer.de>
Subject: Re: ip6tables: accept of IPv6 transport esp packages not possible -
 no rule matches
Date: Fri, 24 Dec 2004 16:59:07 +0100
Message-ID: <5F6ACA5CEF52DBFBF11FBF94@t1mobil.muc.aerasec.de>
References: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: USAGI core <usagi-core@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>
In-Reply-To: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi again,

one update (after playing now with openswan):

> Dec 24 10:22:27 gate kernel: extIN-FW6-default:IN=sit_sixxs OUT=
> MAC=00:11:22:33:44:01->00:11:22:33:44:02 TUNNEL=212.224.  0.188-> 84.000.
> 0. 12 SRC=2001:06f8:0900:0449:0000:0000:0000:0002
> DST=2001:06f8:0900:0094:0000:0000:0000:0002 LEN=116 TC=0 HOPLIMIT=63
> FLOWLBL=0 OPT ( ) PROTO=59

I found a difference in handling of following rules:

#1
ip6tables -A extIN -p all -s 2001:6f8:900:94::2 -d 2001:6f8:900:449::2 -j 
ACCEPT

#2
ip6tables -A extIN -s 2001:6f8:900:94::2 -d 2001:6f8:900:449::2 -j ACCEPT


Rule #1 doesn't match that strangeness, while rule #2 does (and - partially 
- solve my problem now)!

Looks like there is something going wrong in the protocol matching 
algorithm in netfilter6.


So at the moment, I can't filter the traffic, but connection is encrypted.


Perhaps for interesting, using openswan of Fedora Core 3 and following very 
simple configuration:

conn ipv6-location1-location2
        connaddrfamily=ipv6
        left=2001:6f8:900:94::2
        right=2001:6f8:900:449::2
        authby=secret
        type=transport


	Peter
-- 
Dr. Peter Bieringer                        http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                  mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member     http://www.deepspace6.net/
