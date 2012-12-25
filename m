From: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/29] batman-adv: fix random jitter
	calculation
Date: Wed, 26 Dec 2012 06:35:37 +0900
Message-ID: <CAC5umyh1d9XxH2We4e2rjV-OYhbP2ObGC_iwrDeff2hphJ7TzQ@mail.gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
 <1356315256-6572-20-git-send-email-akinobu.mita@gmail.com>
 <20121225112657.GC2604@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
 akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20121225112657.GC2604-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

2012/12/25 Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>:
> On Mon, Dec 24, 2012 at 11:14:06AM +0900, Akinobu Mita wrote:
>> batadv_iv_ogm_emit_send_time() attempts to calculates a random integer
>> in the range of 'orig_interval +- BATADV_JITTER' by the below lines.
>>
>>         msecs = atomic_read(&bat_priv->orig_interval) - BATADV_JITTER;
>>         msecs += (random32() % 2 * BATADV_JITTER);
>>
>> But it actually gets 'orig_interval' or 'orig_interval - BATADV_JITTER'
>> because '%' and '*' have same precedence and associativity is
>> left-to-right.
>>
>> This adds the parentheses at the appropriate position so that it matches
>> original intension.
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
>> Cc: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
>> Cc: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
>> Cc: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
>> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> ---
>
> Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
>
> But I would suggest to apply this change to net, since it is a fix.

I agree.
David, please consider to apply this patch for 3.8-rc*.
