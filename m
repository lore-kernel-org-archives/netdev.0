From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Date: Sat, 19 Sep 2009 07:16:10 +0100 (BST)
Message-ID: <5146.72.11.80.242.1253340970.squirrel@72.11.80.242>
References: <4AA6A25A.5040508@embedded.ufcg.edu.br>
    <20090912183222.GA5706@gerrit.erg.abdn.ac.uk>
    <cb00fa210909141738l60d02cd5p287d990326ce6c3c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	"netdev" <netdev@vger.kernel.org>
To: "Ivo Calado" <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43297 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752774AbZISGQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Sep 2009 02:16:16 -0400
In-Reply-To: <cb00fa210909141738l60d02cd5p287d990326ce6c3c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Also separated the conditions
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((len <=3D 0) ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (!tfrc_lh_closed_check(cur,
>> cong_evt->tfrchrx_ccval))) {
>> back into
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (len <=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!tfrc_lh_closed_check(cur, cong_e=
vt->tfrchrx_ccval))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>>
>
> Thanks!
Yes I know, the above change is reintroduced by patch 2/2. Only found
out after I had gone through this one.


>> The following function pokes a hole in thei so far "abstract" data t=
ype;
>> the convention has been to access the internals of the struct only v=
ia
>> get-functions:
>>
>> static inline struct tfrc_loss_interval
>> =A0 =A0 =A0 =A0*tfrc_lh_get_loss_interval(struct tfrc_loss_hist *lh,=
 const u8 i)
>> {
>> =A0 =A0 =A0 =A0BUG_ON(i >=3D lh->counter);
>> =A0 =A0 =A0 =A0return lh->ring[LIH_INDEX(lh->counter - i - 1)];
>> }
>>
>> (You use it in patch 3/5 to gain access to li_ccval and li_losses.
>> Better would be to have two separate accessor functions.)
>>
>
> Okay, I will fix this.
>
It would be great but is secondary at this stage. The primary objective
should be to get a common prototype out soon, and then verify that it i=
s
correct. I expect several rewrites of other code to make this possible,
so the above detail can also be fixed once a prototype has been found t=
o
work satisfactorily.

