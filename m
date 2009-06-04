From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
	802.15.4 devices
Date: Thu, 4 Jun 2009 19:14:28 +0400
Message-ID: <bc64b4640906040814m1756ea13s19e20592ecf90e9b@mail.gmail.com>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>
	 <1244021964.10665.5.camel@johannes.local>
	 <20090603.030911.162861804.davem@davemloft.net>
	 <20090603105256.GB20508@doriath.ww600.siemens.net>
	 <1244027110.1693.9.camel@johannes.local>
	 <20090603122744.GC20508@doriath.ww600.siemens.net>
	 <1244124749.22576.71.camel@johannes.local>
	 <bc64b4640906040751i3c64c317i4eedb7d53307092a@mail.gmail.com>
	 <4A27E448.3040305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4A27E448.3040305-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/4 Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>:
> Dmitry Eremin-Solenikov wrote:
>>
>> 2009/6/4 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>:
>>>
>>> On Wed, 2009-06-03 at 16:27 +0400, Dmitry Eremin-Solenikov wrote:
>>>
>>>>>> +static int ieee802154_nl_put_failure(struct sk_buff *msg)
>>>>>> +{
>>>>>> + void *hdr =3D genlmsg_data(NLMSG_DATA(msg->data)); /* XXX: nlh=
 is
>>>>>> right at the start of msg */
>>>>>> + genlmsg_cancel(msg, hdr);
>>>>>> + nlmsg_free(msg);
>>>>>> + return -ENOBUFS;
>>>>>> +}
>>>>>
>>>>> This seems weird.
>>>>
>>>> Why?
>>>
>>> Because it's strange to cancel then free?
>>
>>> From looking at the other code, the usual pattern for netlink is
>>
>> (please, correct me if I'm wrong):
>>
>> int fill (....)
>> {
>> =A0 genlmsg_put();
>> =A0 NLA_PUT(...)
>> =A0 NLA_PUT(...)
>> =A0 return genlmsg_end();
>>
>> nla_put_failure:
>> =A0 genlmsg_cancel();
>> =A0 return -EMSGSIZE;
>> }
>>
>> int cmd(...)
>> {
>> =A0 =A0int rc;
>> =A0 =A0nlmsg_new();
>>
>> =A0 =A0rc =3D fill();
>> =A0 =A0if (rc < 0)
>> =A0 =A0 =A0 =A0goto out;
>>
>> =A0 =A0genlmsg_unicast();
>>
>> out:
>> =A0 =A0nlmsg_free();
>> =A0 =A0return -ENOBUFS;
>> }
>>
>> This is equivalent to our code:
>>
>> sk_buff *new()
>> {
>> =A0 msg =3D nlmsg_new();
>> =A0 genlmsg_put();
>> =A0 return msg;
>> }
>
> canceling messages is only necessary in fill functions that are
> also used for dumps, where as many elements are stuffed in the
> skb as possible. When the last element doesn't completely fit,
> its removed again (canceled) and put into the next skb.

Understood. So you'd suggest just to drop the genlmsg_cancel()
from the failure call chain?


--=20
With best wishes
Dmitry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
