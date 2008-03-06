From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch (for 2.6.25?) 1/2] bluetooth: hci_core: defer
 hci_unregister_sysfs()
Date: Wed, 05 Mar 2008 18:46:17 -0800 (PST)
Message-ID: <20080305.184617.42952396.davem@davemloft.net>
References: <200803042258.m24Mw6sO001378@imap1.linux-foundation.org>
	<1250A009-2EDE-4203-9472-05F68BC66001@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	alon.barlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, seife-l3A5Bk7waGM@public.gmane.org
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1250A009-2EDE-4203-9472-05F68BC66001-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Date: Wed, 5 Mar 2008 09:48:29 +0100

> > @@ -902,8 +902,6 @@ int hci_unregister_dev(struct hci_dev *h
> >
> > 	BT_DBG("%p name %s type %d", hdev, hdev->name, hdev->type);
> >
> > -	hci_unregister_sysfs(hdev);
> > -
> > 	write_lock_bh(&hci_dev_list_lock);
> > 	list_del(&hdev->list);
> > 	write_unlock_bh(&hci_dev_list_lock);
> > @@ -915,6 +913,8 @@ int hci_unregister_dev(struct hci_dev *h
> >
> > 	hci_notify(hdev, HCI_DEV_UNREG);
> >
> > +	hci_unregister_sysfs(hdev);
> > +
> > 	__hci_dev_put(hdev);
> 
> I never got a chance to test this one in a proper way, but from a  
> logic point of view it makes sense and thus it is acked by me. I also  
> trust Stefan that he fully tested it.

Also applied to net-2.6
--
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
