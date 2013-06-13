From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: add support for MOST protocol
Date: Thu, 13 Jun 2013 02:53:32 -0700 (PDT)
Message-ID: <20130613.025332.2181739661784418723.davem@davemloft.net>
References: <cover.1370856733.git.asnaghi@st.com>
	<7d70dd76e3e756ca98414247213b7e8fad7034c9.1370856733.git.asnaghi@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@gnudd.com, federico.vaga@gmail.com
To: giancarlo.asnaghi@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7d70dd76e3e756ca98414247213b7e8fad7034c9.1370856733.git.asnaghi@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Date: Mon, 10 Jun 2013 14:52:25 +0200

> This patch adds core support for the MOST protocol. More information
> about the protocol can be found at: http://www.mostcooperation.com/
> 
> See the lkml message "[PATCH 0/3] MOST network protocol" sent on Jun
> 10th 2013 about this code and the missing "Signed-off" lines.

There are a lot of coding style issues in these patches, I'm only going
to point out one:

> +		if (most_sk(sk)->dev_id == dev_id &&
> +			most_sk(sk)->channel_type == most_cb(skb)->channel_type
> +			&& most_sk(sk)->rx_channel == most_cb(skb)->channel &&
> +			sk->sk_state == MOST_BOUND) {

Frankly, this is very ugly, even ignoring the standard coding style rules.

First of all, never put the operators at the beginning of the line.
This code not only does that, but it mixes style every other line,
that's terrible.

Secondly, each line of the conditional after the first must line up
at the first column after the openning parenthesis of the if() statement
(or any inner parenthetical grouping the expression is a part of).

You achieve such alignment using the appropriate number of TAB and
space characters necessary to do so, for example:

	if (x &&
	    y &&
	    z) {
		...
	}
