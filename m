From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Mon, 12 Jan 2015 15:19:27 -0800
Message-ID: <CAEP_g=-QiYG8P7ZaZ54rA72tk2W=t44Wrvz3ju8UFccNgAY4iQ@mail.gmail.com>
References: <cover.1421064100.git.tgraf@suug.ch> <014606bb741d017675f7728a0bccc4cbed42af4b.1421064100.git.tgraf@suug.ch>
 <CAEP_g=8TqGnftZa_scKODa2ra7gsV6ov_5J+Lbfq+4bFDZjiBw@mail.gmail.com>
 <20150112224749.GB11857@casper.infradead.org> <CAEP_g=-85jmr3b6J0xfy661G_Ffh2LkOH=FazhfhVBwSjwHQNA@mail.gmail.com>
 <20150112225944.GC11857@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:51444 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751223AbbALXTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 18:19:48 -0500
Received: by mail-qg0-f43.google.com with SMTP id z107so20142127qgd.2
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 15:19:48 -0800 (PST)
In-Reply-To: <20150112225944.GC11857@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 2:59 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/12/15 at 02:50pm, Jesse Gross wrote:
>> On Mon, Jan 12, 2015 at 2:47 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > On 01/12/15 at 11:23am, Jesse Gross wrote:
>> >> On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
>> >> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> >> > index 4d52aa9..b148739 100644
>> >> > --- a/drivers/net/vxlan.c
>> >> > +++ b/drivers/net/vxlan.c
>> >> > @@ -568,7 +569,8 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head, struct sk_buff
>> >> >                         continue;
>> >> >
>> >> >                 vh2 = (struct vxlanhdr *)(p->data + off_vx);
>> >> > -               if (vh->vx_vni != vh2->vx_vni) {
>> >> > +               if (vh->vx_flags != vh2->vx_flags ||
>> >> > +                   vh->vx_vni != vh2->vx_vni) {
>> >>
>> >> It's probably better to do a memcmp over the entire header. There's no
>> >> guarantee that new fields will be entirely represented by flags.
>> >
>> > vx_flags covers the entire first 32 bit of vxlanhdr so it's
>> > equivalent to a memcmp() already. I can change it to memcmp() if
>> > you think that's more readable.
>>
>> I was actually referring to the reserved 8 bit chunk after the VNI.
>> This could potentially be used for something in the future.
>
> Shouldn't that be covered by vh->vx_vni != vh2->vx_vni? I may
> still misunderstand, sorry.

Ah, sorry. I see that vx_vni is 4 bytes instead of 3 bytes of the
actual VNI. I agree that the whole header is covered for GRO purposes.
The definition of the VNI field is a little confusing but I guess it's
more efficient than the alternative.
