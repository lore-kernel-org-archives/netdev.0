From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [PATCH 3.3.0 1/3] net:phy:bcm63xx: remove unnecessary code
Date: Tue, 03 Apr 2012 10:49:41 +0100
Message-ID: <4F7AC7B5.3040301@st.com>
References: <1333383895-23889-1-git-send-email-srinivas.kandagatla@st.com>	 <1333384945.15422.14.camel@joe2Laptop> <4F79D91A.2030403@st.com> <1333386157.15422.21.camel@joe2Laptop>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:58676 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751656Ab2DCJvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 05:51:35 -0400
In-Reply-To: <1333386157.15422.21.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, I have audited all the drivers. none of them return positive values.
In general, I think phy_write should return either 0 or an error code
and *NOT* positive values.
Any mdio bus driver returning positive values for phy_writes will break
the phylib too.

On 02/04/12 18:02, Joe Perches wrote:
> On Mon, 2012-04-02 at 17:51 +0100, Srinivas KANDAGATLA wrote:
>> On 02/04/12 17:42, Joe Perches wrote:
>>> On Mon, 2012-04-02 at 17:24 +0100, Srinivas KANDAGATLA wrote:
>>> Do these really make any functional difference?
>> No it does not make any functional difference.
>>> Doesn't the compiler generate the same output?
>> I think it will not generate same output.
> Yes, you are right.  The code currently returns 0 for
> non-error cases and you've changed it to possibly
> return a positive value.
>
> Have you checked all the callers to make sure this
> doesn't introduce a new defect?
>
