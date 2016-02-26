From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Fri, 26 Feb 2016 19:54:57 +0100
Message-ID: <CA+BoTQnYiSdzn99_xZPs9X2JO3SijXj10C2ezVr_8OEZvNCStg@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<56D081F1.3030801@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Tim Shepard <shep@alum.mit.edu>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37980 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422711AbcBZSy6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 13:54:58 -0500
Received: by mail-wm0-f49.google.com with SMTP id a4so81736219wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 10:54:57 -0800 (PST)
In-Reply-To: <56D081F1.3030801@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 February 2016 at 17:48, Felix Fietkau <nbd@openwrt.org> wrote:
[...]
>> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
>> index af584f7cdd63..f42f898cb8b5 100644
>> --- a/net/mac80211/tx.c
>> +++ b/net/mac80211/tx.c
>> + [...]
>> +static void ieee80211_txq_enqueue(struct ieee80211_local *local,
>> +                               struct txq_info *txqi,
>> +                               struct sk_buff *skb)
>> +{
>> +     struct ieee80211_fq *fq =3D &local->fq;
>> +     struct ieee80211_hw *hw =3D &local->hw;
>> +     struct txq_flow *flow;
>> +     struct txq_flow *i;
>> +     size_t idx =3D fq_hash(fq, skb);
>> +
>> +     flow =3D &fq->flows[idx];
>> +
>> +     if (flow->txqi)
>> +             flow =3D &txqi->flow;
> I'm not sure I understand this part correctly, but shouldn't that be:
>         if (flow->txqi && flow->txqi !=3D txqi)

You're correct. Good catch, thanks!


Micha=C5=82
