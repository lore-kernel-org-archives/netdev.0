From: "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 4/4] bnx2i: Add bnx2i iSCSI driver.
Date: Wed, 20 May 2009 15:22:44 -0700
Message-ID: <1242858164.10180.316.camel@HP1>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com> <1241208039-6813-5-git-send-email-mchan@broadcom.com> <4A01BF6A.90707@cs.wisc.edu> <1241715824.9177.8.camel@HP1> <4A034C2A.50107@cs.wisc.edu> <1242697859.10180.147.camel@HP1> <4A12C08A.1080600@cs.wisc.edu> <1242766039.10180.178.camel@HP1> <4A132B6B.5030008@cs.wisc.edu> <1242838735.10180.228.camel@HP1> <4A14608F.6070800@cs.wisc.edu>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org" <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Karen Xie" <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, "Anil Veerabhadrappa" <anilgv-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, "Benjamin Li" <benli-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: "open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org" <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, "Mike Christie" <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <4A14608F.6070800-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org



On Wed, 2009-05-20 at 12:57 -0700, Mike Christie wrote:
> Michael Chan wrote:
> > diff --git a/include/scsi/iscsi_if.h b/include/scsi/iscsi_if.h
> > index 2c1a4af..0990dbb 100644
> > --- a/include/scsi/iscsi_if.h
> > +++ b/include/scsi/iscsi_if.h
> > @@ -23,6 +23,9 @@
> >  
> 
> > + */
> > +struct iscsi_path {
> > +	uint64_t	handle;
> > +	uint8_t		mac_addr[6];
> > +	uint8_t		mac_addr_old[6];
> > +	uint32_t	ip_addr_len;	/* 4 or 16 */
> > +	union {
> > +		struct in_addr	v4_addr;
> > +		struct in6_addr	v6_addr;
> > +	} src;
> > +	union {
> > +		struct in_addr	v4_addr;
> > +		struct in6_addr	v6_addr;
> 
> I think we have to include in6.h and in.h in this file, right? iser 
> would not compile with this patch without it. If that is right and it 
> works for you now, I can just fix it when I merge the patch.
> 

Yes, either include these files here in iscsi_if.h or include them in
places where iscsi_if.h is included.  Which way do you prefer?
