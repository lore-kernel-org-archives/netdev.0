From: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: skb->priority usage in wireless frame classification
Date: Fri, 16 Dec 2011 10:42:20 +0100
Message-ID: <CAGXE3d_=OA+EvX8Q=gELDHSESAQpgt_EavTWGTNLYMnjURLJWw@mail.gmail.com>
References: <CAGXE3d_ouo4KzQA0-ysLz_RwcqoTc5Sg4V6BZZJP0TJewzNOxw@mail.gmail.com>
	<CAA93jw4-OEbiSpQM+SJn7R0uAe0o-nw0kwgvjVkL4w4AeWQtjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA93jw4-OEbiSpQM+SJn7R0uAe0o-nw0kwgvjVkL4w4AeWQtjQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2011 at 10:35 AM, Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote=
:
> On Fri, Dec 16, 2011 at 9:45 AM, Helmut Schaa
> <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
>> [Adding netdev]
>>
>> Maybe someone from the netdev people can shed some light on this.
>> We've got the following code in net/wireless/util.c for frame classi=
fication
>> (cfg80211_classify8021d):
>>
>> /* skb->priority values from 256->263 are magic values to
>> * directly indicate a specific 802.1d priority. =A0This is used
>> * to allow 802.1d priority to be passed directly in from VLAN
>> * tags, etc.
>> */
>> if (skb->priority >=3D 256 && skb->priority <=3D 263)
>> =A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return skb->priority - 256;
>>
>> I was just thinking about making use of this for some internal mac80=
211
>> QoS handling. But is this code still valid? At least I haven't found=
 anything
>> in the 802.1q code :(
>
> I made use of the above 'feature' while prototyping some Diffserv wor=
k
> with iptables. I have no idea if there are users of this obscure
> overloading of priority in userspace....
>
> The vlan code at least used to do something like this:
>
> net/8021q/vlan.h: * =A0 =A0 @vlan_qos: vlan priority: (skb->priority =
<< 13) & 0xE000

Yeah, I saw that too but +256 would be << 8 and not << 13.

Helmut
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
