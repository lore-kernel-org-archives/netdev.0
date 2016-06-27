From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCH RFC 3/3] ARM64: dts: meson-gxbb: use the new meson8b DWMAC glue
Date: Mon, 27 Jun 2016 13:33:49 +0200
Message-ID: <CAFBinCBcv+4MHe9sFeGLRRRvb7hjX4=XYOtxN_rO1yzVFZisaQ@mail.gmail.com>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
 <20160625165013.15917-4-martin.blumenstingl@googlemail.com>
 <20160627092448.GA3275@localhost> <CAFBinCB6i2-ZUDupAXUZkQO9y93rtCvguD_avdY=Ze72wxQKpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-amlogic@lists.infradead.org, mark.rutland@arm.com,
	khilman@baylibre.com, robh+dt@kernel.org, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: Carlo Caione <carlo@caione.org>, mturquette@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35997 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbcF0LeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 07:34:15 -0400
Received: by mail-wm0-f43.google.com with SMTP id f126so96428372wma.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 04:34:14 -0700 (PDT)
In-Reply-To: <CAFBinCB6i2-ZUDupAXUZkQO9y93rtCvguD_avdY=Ze72wxQKpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 12:44 PM, Martin Blumenstingl
<martin.blumenstingl@googlemail.com> wrote:
> On Mon, Jun 27, 2016 at 11:24 AM, Carlo Caione <carlo@caione.org> wrote:
>> A syscon is a region containing a set of miscellaneous registers used
>> for several reasons by several devices [1]. It this case there is really
>> no need to define a new syscon node since those two registers are only
>> used by your driver.
> I can easily change it back if that's the way to go.
> Before I do that: could you please confirm that "mp2_clk_out" (which
> is controlled by PRG_ETH0/offset 0x0 bits 7-9) is not something which
> has to be available through the common clk framework?
there was just an IRC discussion with Carlo on this topic:
We tried to find whether PRG_ETH0 is used to actually configure
"mp2_clk_out". Carlo brought up that it could also be the case that
the ethernet block simply needs to be informed about the rate of the
mp2_clk_out (which is *probably* the "mpll2" clock).

I'm adding Michael Turquette to this mail, maybe you can comment on this topic.

If it turns out that the etthernet block just has to know about the
clock rate then we have two tasks:
1. identify why the mpll2 rate returns 0 on my GXBB device
2. change my patch so the new DWMAC glue gets a reference to the mpll2
clock and then use "clk_get_rate(mpll2) / (250 * 1000000)" to
configure the PRG_ETH0_MP2_CLK bits.
