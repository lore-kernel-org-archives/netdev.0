From: Vincent Palatin <vpalatin@chromium.org>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: keep PHY up for WoL
Date: Mon, 6 Jun 2016 14:00:58 -0700
Message-ID: <CAP_ceTwY3uaR7s44Ffp3MKF_U0Sg0nN3t5QAxX1fP4wOUS5m9w@mail.gmail.com>
References: <1464974960-26672-1-git-send-email-vpalatin@chromium.org> <1922621.IgQfJVQxEA@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Douglas Anderson <dianders@chromium.org>
To: =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1922621.IgQfJVQxEA@diego>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 6, 2016 at 1:45 PM, Heiko St=C3=BCbner <heiko@sntech.de> wr=
ote:
> Hi,
>
> Am Freitag, 3. Juni 2016, 10:29:20 schrieb Vincent Palatin:
>> Do not shutdown the PHY if Wake-on-Lan is enabled, else it cannot wa=
ke
>> us up.
>>
>> Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c index 0cd3ecf..2e45=
e75
>> 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> @@ -534,6 +534,10 @@ static int rk_gmac_init(struct platform_device =
*pdev,
>> void *priv) struct rk_priv_data *bsp_priv =3D priv;
>>       int ret;
>>
>> +     /* Keep the PHY up if we use Wake-on-Lan. */
>> +     if (device_may_wakeup(&pdev->dev))
>> +             return 0;
>> +
>
> Hmm, this looks like it would also block the initial setup of clocks =
and phy?

Yes, that's bad. Doug told me so but I forget to CC him on the
previous submission.
I will do another version.

> platform_device + device struct are created before probe gets called,=
 so
> something could set the wakeup flag before the driver initially probe=
s?

The device tree 'wakeup' attribute likely does it.

--=20
Vincent
