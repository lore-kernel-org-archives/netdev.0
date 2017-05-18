From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] wcn36xx: Pass used skb to ieee80211_tx_status()
Date: Thu, 18 May 2017 09:00:07 +0200
Message-ID: <1495090807.2442.23.camel@sipsolutions.net>
References: <20170426220444.10539-1-bjorn.andersson@linaro.org>
 <1493281332.2529.1.camel@sipsolutions.net> <20170428234247.GQ15143@minitux>
 <87fugkrchl.fsf@kamboji.qca.qualcomm.com>
 <1495026867.2442.9.camel@sipsolutions.net> <20170518050538.GL12920@tuxbook>
 (sfid-20170518_070538_893255_D1A04092)
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "nicolas.dechesne@linaro.org" <nicolas.dechesne@linaro.org>,
 David Brown <david.brown@linaro.org>, Kalle Valo <kvalo@qca.qualcomm.com>,
 "k.eugene.e@gmail.com" <k.eugene.e@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Andy Gross <andy.gross@linaro.org>,
 "wcn36xx@lists.infradead.org" <wcn36xx@lists.infradead.org>,
 "linux-soc@vger.kernel.org" <linux-soc@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170518050538.GL12920@tuxbook>
 (sfid-20170518_070538_893255_D1A04092)
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-05-17 at 22:05 -0700, Bjorn Andersson wrote:
> 
> It seems very important to a lot of people...

I get blinking, I guess, but I don't get toggling for every packet :)
The throughput thing we did in iwlwifi seems like a so much better
idea. Not that it really matters for this discussion though.

> But if ieee80211_free_txskb() is the counterpart of
> ieee80211_tx_status() then we should be able to push the
> ieee80211_led_tx() call down into ieee80211_report_used_skb() and
> handle both cases.

Yeah, I guess that works.

> The ieee80211_free_txskb() seems to be used in various cases where we
> discard skbs, but perhaps this is not an issue in reality.

Those should be code paths that are really rare, when we fail
allocations in some places, etc. So it shouldn't really lead to any
problems.

> Looking around it seems that we either have a call to free_txskb() or
> one of the tx_status(); 

Yes, you're right - we always need one of those for each SKB that
passed through mac80211, everything else is already a bug.

> where the _noskb() would need some special
> handling. Are there others or would it be reasonable to add a call in
> this one "special" case?

Now that I think more about it, the _noskb() doesn't actually make
sense - it's for a separate status report, pretty much only for rate
control feedback, but the SKB should be freed separately with
free_txskb().

johannes
