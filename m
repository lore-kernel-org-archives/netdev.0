From: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 21/29] drivers, s390: convert fc_fcp_pkt.ref_cnt from
 atomic_t to refcount_t
Date: Wed, 8 Mar 2017 15:06:53 +0100
Message-ID: <36e6c54c-5e4b-fe16-86e2-fdef7a52d048@suse.de>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-22-git-send-email-elena.reshetova@intel.com>
 <536a58ba-8896-5639-cab9-bd2f13bed325@suse.de>
 <2236FBA76BA1254E88B949DDB74E612B41C5615F@IRSMSX102.ger.corp.intel.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org" <xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
 <linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
 "linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org" <devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org>,
 "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org" <fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>,
 "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org" <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 "devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org" <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>,
 "target-devel-u79uwXL29Tb/PtFMR13I2A@public.gmane.org
To: "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <open-iscsi+bncBDVNRMMDUUIBB747QDDAKGQEYPGNNBQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B41C5615F-kPTMFJFq+rFP9JyJpTNKArfspsVTdybXVpNB7YpNyf8@public.gmane.org>
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On 03/08/2017 02:48 PM, Reshetova, Elena wrote:
>> On 03/06/2017 03:21 PM, Elena Reshetova wrote:
>>> refcount_t type and corresponding API should be
>>> used instead of atomic_t when the variable is used as
>>> a reference counter. This allows to avoid accidental
>>> refcounter overflows that might lead to use-after-free
>>> situations.
>>
>> The subject is wrong, should be something like "scsi: libfc convert
>> fc_fcp_pkt.ref_cnt from atomic_t to refcount_t" but not s390.
>>
>> Other than that
>> Acked-by: Johannes Thumshirn <jth-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>
> Turns out that it is better that all these patches go through the respect=
ive maintainer trees, if present.
> If I send an updated patch (with subject fixed), could you merge it throu=
gh your tree?

Yes, but this would be the normal scsi tree from Martin and James.

Please include my Ack in the re-sends.

Thanks a lot,
	Johannes


--=20
Johannes Thumshirn                                          Storage
jthumshirn-l3A5Bk7waGM@public.gmane.org                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg
GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N=C3=BCrnberg)
Key fingerprint =3D EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850

--=20
You received this message because you are subscribed to the Google Groups "=
open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
