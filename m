From: kuznet@ms2.inr.ac.ru
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Fri, 5 Mar 2004 01:02:18 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403042202.BAA10586@yakov.inr.ac.ru>
References: <Pine.LNX.4.58.0403042229210.1130@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, niv@us.ibm.com, ak@suse.de, ruddk@us.ibm.com,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ja@ssi.bg (Julian Anastasov)
In-Reply-To: <Pine.LNX.4.58.0403042229210.1130@u.domain.uli> from "Julian Anastasov" at Мар 04, 2004 10:56:26 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> - do we need to walk all tos values for ip_rt_redirect in the same
> way as for ip_rt_frag_needed,

Well, it is just the same thing (except for one thing, that ignored
redirects are harmless)


> - from another thread: whether ICMP redirects modify only
> routes via gateway when shared_media is ON:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=107109827516060&w=2

"message but we are sure we hit the target IP directly"

You cannot be sure, actually. This happens and resolves the situation
when the things sort ip route add default dev eth0 are used i.e. host
does not know real prefixes.

If this is a security issue (I do not see actually, the things on link
can be screwed via proxy arp et all in any case), make it a separate option
or even better use IN_DEV_SEC_REDIRECTS(in_dev) like similar paranoid case
for !shared_media case.

Alexey
