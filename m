From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Bridge] RE: [VLAN] Re: [PATCH/RFC] Let {ip, arp}tables "see"
  bridged VLAN tagged{I,AR}P packets
Date: Wed, 08 Oct 2003 09:34:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F843C8C.4030100@candelatech.com>
References: <5B537508CDBED3118403009027745A210B8C14A1@knant18.kna.flextronics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Tommy Christensen'" <tommy.christensen@tpack.net>, netdev@oss.sgi.com,
        bridge <bridge@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Linux 802.1Q VLAN" <vlan@wanfear.com>
In-Reply-To: <5B537508CDBED3118403009027745A210B8C14A1@knant18.kna.flextronics.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Darnell wrote:
> -----Original Message-----
> 
>>From: Tommy Christensen [mailto:tommy.christensen@tpack.net]
>>Sent: Wednesday, October 08, 2003 10:09 AM
>>To: Christian Darnell
>>Cc: 'Linux 802.1Q VLAN'; Bart De Schuymer; netdev@oss.sgi.com; bridge
>>Subject: Re: [Bridge] RE: [VLAN] Re: [PATCH/RFC] Let {ip, arp}tables
>>"see" bridged VLAN tagged{I,AR}P packets
>>
>>
>>
>>This is because the VLAN code is mangling shared data.
>>You need to do something like this:
>>
>>
>>--- linux-2.4/net/8021q/vlan_dev.c.org	2003-02-25 15:23:09.000000000
>>+0100
>>+++ linux-2.4/net/8021q/vlan_dev.c	2003-10-07 16:01:29.000000000 +0200
>>@@ -75,7 +75,12 @@
>>static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff
>>*skb)
>>{
>>	if (VLAN_DEV_INFO(skb->dev)->flags & 1) {
>>-		skb = skb_share_check(skb, GFP_ATOMIC);
>>+		if (skb_shared(skb) || skb_cloned(skb)) {
>>+			struct sk_buff *nskb;
>>+			nskb = skb_copy(skb, GFP_ATOMIC);
>>+			kfree_skb(skb);
>>+			skb = nskb;
>>+		}

Thanks for catching that!

So, what good is skb_share_check then?
Maybe we should have a skb_share_or_cloned_check() ?

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
