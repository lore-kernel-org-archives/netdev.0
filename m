From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 22:56:28 +0100
Message-ID: <1354917388.9124.24.camel@jlt4.sipsolutions.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
	 <1354915824.9124.11.camel@jlt4.sipsolutions.net>
	 <1354916768.4530.18.camel@tiger2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Eric Leblond <eric-EVVnsjFE0OfYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354916768.4530.18.camel@tiger2>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HI,

> > That's interesting. A single one seems odd. I might have expected two,
> > but not one. Well, since you removed the crash ... I guess I'll have to
> > believe that there's just one and the second one doesn't show up because
> > we crashed before :-)
> 
> It was the case with initial code but I've suppressed the BUG() call and
> replaced it with a return ;)

Right. Well, does it actually still work then? I wonder if then you
don't see a second packet because the first one doesn't make it
through ... I'm thinking that this is just an internal af_packet problem
with multiple listeners.


> I've no simple code available to test it. I've add the problem when
> running suricata. Maybe you could use it. It is packaged in most
> distribution now.
> To enable packet fanout. Modify default /etc/suricata/suricata.yaml to
> have something like:
> af-packet:
>   - interface: wlan0
>     # Number of receive threads (>1 will enable experimental flow pinned
>     # runmode)
>     threads: 3

That'll should do, thanks.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
