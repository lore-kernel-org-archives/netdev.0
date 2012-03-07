From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/6] stmmac: Define MDC clock selection macros.
Date: Wed, 07 Mar 2012 08:19:16 +0100
Message-ID: <4F570BF4.5070706@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <4F54CF00.6030005@st.com> <4F57067E.5090104@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:47305 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751279Ab2CGHUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 02:20:12 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 332453BB
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 07:20:10 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8A41D1679
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 07:20:10 +0000 (GMT)
In-Reply-To: <4F57067E.5090104@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/2012 7:55 AM, Deepak SIKRI wrote:
> Hello Peppe,
> 
>>
>> I have some concerns about this patch.
>>
>> We want to have some defines to help on setting the clk_csr (that is is
>> a clk divisor).
>>
>> When you program the "CSR Clock Range" bits in the GMII Address Register
>> you can also set the bit 5 (not supported in older devices e.g. 3.41a).
>> In this case, the defines below do not cover all the cases, I mean:
>>
>> 1000 clk_csr_i/4
>> 1001 clk_csr_i/6
>> 1010 clk_csr_i/8
>> 1011 clk_csr_i/10
>> 1100 clk_csr_i/12
>> 1101 clk_csr_i/14
>> 1110 clk_csr_i/16
>> 1111 clk_csr_i/18
> 
> I agree that these macros have been missed. But lets take the change
> suggested as a separate patch,
> as this would then be integrated along with the driver.
> The driver by default is considering the 2.5MHz MDIO clock option only.
> In this case we require an extra
> variable to differentiate specification which is higher than IEEE spec
> of 2.5MHz.

ok, we will have them in a another patch. At any rate, I ask you to add
a FIXME in the code and detail this issue in the patch comment.

> 
>>> +/* MDC Clock Selection define*/
>>> +#define    STMMAC_CLK_RANGE_60_100M    0    /* MDC = Clk/42 */
>>> +#define    STMMAC_CLK_RANGE_100_150M    1    /* MDC = Clk/62 */
>>> +#define    STMMAC_CLK_RANGE_20_35M        2    /* MDC = Clk/16 */
>>> +#define    STMMAC_CLK_RANGE_35_60M        3    /* MDC = Clk/26 */
>>> +#define    STMMAC_CLK_RANGE_150_250M    4    /* MDC = Clk/102 */
>>> +#define    STMMAC_CLK_RANGE_250_300M    5    /* MDC = Clk/122 */
>> I suggest you to rename these macros as:
>>
>> #define STMMAC_CSR_60_100M    0    /* MDC = Clk/42 */
>> ...
> 
> Ok
> 
>>
>> Also, macros CSR_F_20M should be totally removed.
> 
> ok
> 
>> Peppe
>>
>>> +
>>>   /* Platfrom data for platform device structure's platform_data
>>> field */
>>>
>>>   struct stmmac_mdio_bus_data {
> Regards
> Deepak
> 
