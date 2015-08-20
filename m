From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last
 TSO segment
Date: Thu, 20 Aug 2015 07:13:19 -0700
Message-ID: <1440079999.6610.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
	 <1439994266.6610.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
	 <1440016762.6610.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8257BD@hasmsx107.ger.corp.intel.com>
	 <1440076269.6610.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E82654B@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32E82654B-Jy8z56yoSI9wl47ZQwxUxrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-20 at 13:53 +0000, Grumbach, Emmanuel wrote:

> I do keep the original skb: it becomes the first 802.11 packet generated
> from that LSO skb. Thing is that it will be freed first and I wanted the
> *last packet* to release the pressure on the socket.

Just change this to free it last. It is that simple.

> So I guess that skb_still_in_host_queue will still find it and avoid
> retransmissions at least until the first skb of the LSO is freed.
> But unless you are fine with releasing the pressing on the socket as
> soon as the *first* 802.11 skb is freed, I need that code.
> 
> I'll try to look at dev->gso_max_size that you mentioned below. This can
> really be a game changer for me.

Honestly, if your TSO patches do not use existing infra, I will NACK
them.

If existing infra is not good enough, you have the power to change it.

Fully re-implementing TSO (or GRO) in a device driver is a non starter.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
