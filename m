From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
 	802.15.4 devices
Date: Thu, 04 Jun 2009 17:12:08 +0200
Message-ID: <4A27E448.3040305@trash.net>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>	 <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>	 <1244021964.10665.5.camel@johannes.local>	 <20090603.030911.162861804.davem@davemloft.net>	 <20090603105256.GB20508@doriath.ww600.siemens.net>	 <1244027110.1693.9.camel@johannes.local>	 <20090603122744.GC20508@doriath.ww600.siemens.net>	 <1244124749.22576.71.camel@johannes.local> <bc64b4640906040751i3c64c317i4eedb7d53307092a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bc64b4640906040751i3c64c317i4eedb7d53307092a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dmitry Eremin-Solenikov wrote:
> 2009/6/4 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>:
>> On Wed, 2009-06-03 at 16:27 +0400, Dmitry Eremin-Solenikov wrote:
>>
>>>>> +static int ieee802154_nl_put_failure(struct sk_buff *msg)
>>>>> +{
>>>>> + void *hdr = genlmsg_data(NLMSG_DATA(msg->data)); /* XXX: nlh is right at the start of msg */
>>>>> + genlmsg_cancel(msg, hdr);
>>>>> + nlmsg_free(msg);
>>>>> + return -ENOBUFS;
>>>>> +}
>>>> This seems weird.
>>> Why?
>> Because it's strange to cancel then free?
> 
>>From looking at the other code, the usual pattern for netlink is
> (please, correct me if I'm wrong):
> 
> int fill (....)
> {
>    genlmsg_put();
>    NLA_PUT(...)
>    NLA_PUT(...)
>    return genlmsg_end();
> 
> nla_put_failure:
>    genlmsg_cancel();
>    return -EMSGSIZE;
> }
> 
> int cmd(...)
> {
>     int rc;
>     nlmsg_new();
> 
>     rc = fill();
>     if (rc < 0)
>         goto out;
> 
>     genlmsg_unicast();
> 
> out:
>     nlmsg_free();
>     return -ENOBUFS;
> }
> 
> This is equivalent to our code:
> 
> sk_buff *new()
> {
>    msg = nlmsg_new();
>    genlmsg_put();
>    return msg;
> }

canceling messages is only necessary in fill functions that are
also used for dumps, where as many elements are stuffed in the
skb as possible. When the last element doesn't completely fit,
its removed again (canceled) and put into the next skb.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
