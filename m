From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Sat, 6 Mar 2004 13:55:03 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403061337040.1158@u.domain.uli>
References: <200403042202.BAA10586@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, niv@us.ibm.com, ak@suse.de, ruddk@us.ibm.com,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200403042202.BAA10586@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 5 Mar 2004 kuznet@ms2.inr.ac.ru wrote:

> > routes via gateway when shared_media is ON:
> >
> > http://marc.theaimsgroup.com/?l=linux-netdev&m=107109827516060&w=2
>
> "message but we are sure we hit the target IP directly"
>
> You cannot be sure, actually. This happens and resolves the situation
> when the things sort ip route add default dev eth0 are used i.e. host
> does not know real prefixes.
>
> If this is a security issue (I do not see actually, the things on link
> can be screwed via proxy arp et all in any case), make it a separate option
> or even better use IN_DEV_SEC_REDIRECTS(in_dev) like similar paranoid case
> for !shared_media case.

	I now see, may be better to stay as before, IN_DEV_SEC_REDIRECTS
if used, can break the shared_media feature.

	Anyways, I prepared a final version:

http://www.ssi.bg/~ja/tmp/tos-8.diff

	It passes simple tests. I hope it is ready for inclusion
after eventual tuning. Compared to previous versions I removed the
'rth->rt_dst == rth->rt_gateway' check for redirects and renamed the
flags.

Regards

--
Julian Anastasov <ja@ssi.bg>
