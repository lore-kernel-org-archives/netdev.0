From: "Christopher J. PeBenito" <cpebenito@tresys.com>
Subject: Re: [PATCH 1/1] secid reconcialiation: Replace unlabeled_t with
	the network_t
Date: Wed, 04 Oct 2006 10:47:34 -0400
Message-ID: <1159973254.14831.71.camel@sgc>
References: <45231F6F.4030509@trustedcs.com>  <4523C655.7010008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tresys.irides.com ([216.250.243.126]:35126 "HELO
	exchange.columbia.tresys.com") by vger.kernel.org with SMTP
	id S1161152AbWJDOrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 10:47:42 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <4523C655.7010008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 10:33 -0400, Paul Moore wrote:
> Venkat Yekkirala wrote:
> > The following replaces unlabeled_t with network_t for
> > better characterization of the flow out/in checks in
> > SELinux, as well as to allow for mls packets to
> > flow out/in from the network since network_t would allow
> > the full range of MLS labels, as opposed to the unlabeled init sid
> > that only allows system-hi.
> > 
> > Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
> > ---
> > This is an incremental patch the secid-reconcilation v4 patchset.
> > 
> > --- net-2.6.sid3/security/selinux/hooks.c	2006-10-01 15:43:12.000000000 -0500
> > +++ net-2.6/security/selinux/hooks.c	2006-10-03 16:43:21.000000000 -0500
> > @@ -3703,7 +3703,8 @@ static int selinux_skb_flow_in(struct sk
> >  	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
> >  	BUG_ON(err);
> >  
> > -	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
> > +	err = avc_has_perm(xfrm_sid, skb->secmark? : SECINITSID_NETMSG,
> > +					SECCLASS_PACKET,
> >  					PACKET__FLOW_IN, NULL);
> >  	if (err)
> >  		goto out;
> > @@ -3900,7 +3901,7 @@ static unsigned int selinux_ip_postroute
> >  				skb->secmark = sksec->sid;
> >  			}
> >  		}
> > -		err = avc_has_perm(skb->secmark, SECINITSID_UNLABELED,
> > +		err = avc_has_perm(skb->secmark, SECINITSID_NETMSG,
> >  				   SECCLASS_PACKET, PACKET__FLOW_OUT, &ad);
> >  	}
> >  out:
> 
> Considering the above change, I wonder if it would also make sense to
> update the secmark to SECINITSID_UNLABELED in the abscence of any
> external labeling (labeled IPsec or NetLabel)?

Wouldn't that make secmark useless in the non labeled networking case?

-- 
Chris PeBenito
Tresys Technology, LLC
(410) 290-1411 x150

