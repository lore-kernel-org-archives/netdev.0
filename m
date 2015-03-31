From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: [PATCH net-next V2 17/23] ptp: stmmac: convert to the 64 bit
 get/set time methods.
Date: Tue, 31 Mar 2015 18:52:08 +0530
Message-ID: <CAJ3bTp6Wd6stScedW=jhqyjx3bty=qFPM1g5Je4+1XVvFBR7iA@mail.gmail.com>
References: <cover.1426973658.git.richardcochran@gmail.com>
	<009374d77dee7633ab0ef1a5d95182b45aaa3f18.1426973658.git.richardcochran@gmail.com>
	<551032AA.3060906@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	=?UTF-8?Q?Stefan_S=C3
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:32884 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbbCaNWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 09:22:09 -0400
Received: by wgoe14 with SMTP id e14so18763472wgo.0
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 06:22:08 -0700 (PDT)
In-Reply-To: <551032AA.3060906@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I too don't have setup now.

--
Rayagond

On Mon, Mar 23, 2015 at 9:05 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> On 3/21/2015 10:39 PM, Richard Cochran wrote:
>>
>> This device stores the number of seconds in a 32 bit register.  So
>> more work is needed on this driver before the year 2038 comes around.
>>
>> Compile tested only.
>
>
> I cannot perform tests on my side, unfortunately. I have no setup at
> this moment. Added Rayagond on copy too
>
> Peppe
>
>
>>
>> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    8 ++++----
>>   1 file changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
>> index c5ee79d8..172f318 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
>> @@ -105,7 +105,7 @@ static int stmmac_adjust_time(struct ptp_clock_info
>> *ptp, s64 delta)
>>    * Description: this function will read the current time from the
>>    * hardware clock and store it in @ts.
>>    */
>> -static int stmmac_get_time(struct ptp_clock_info *ptp, struct timespec
>> *ts)
>> +static int stmmac_get_time(struct ptp_clock_info *ptp, struct timespec64
>> *ts)
>>   {
>>         struct stmmac_priv *priv =
>>             container_of(ptp, struct stmmac_priv, ptp_clock_ops);
>> @@ -135,7 +135,7 @@ static int stmmac_get_time(struct ptp_clock_info *ptp,
>> struct timespec *ts)
>>    * hardware clock.
>>    */
>>   static int stmmac_set_time(struct ptp_clock_info *ptp,
>> -                          const struct timespec *ts)
>> +                          const struct timespec64 *ts)
>>   {
>>         struct stmmac_priv *priv =
>>             container_of(ptp, struct stmmac_priv, ptp_clock_ops);
>> @@ -168,8 +168,8 @@ static struct ptp_clock_info stmmac_ptp_clock_ops = {
>>         .pps = 0,
>>         .adjfreq = stmmac_adjust_freq,
>>         .adjtime = stmmac_adjust_time,
>> -       .gettime = stmmac_get_time,
>> -       .settime = stmmac_set_time,
>> +       .gettime64 = stmmac_get_time,
>> +       .settime64 = stmmac_set_time,
>>         .enable = stmmac_enable,
>>   };
>>
>>
>
