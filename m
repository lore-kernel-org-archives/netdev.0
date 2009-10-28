From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Tue, 27 Oct 2009 23:09:10 -0400
Message-ID: <4AE7B5D6.8070001@gmail.com>
References: <4AE72075.4070702@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932523AbZJ1DJK@vger.kernel.org>
In-Reply-To: <4AE72075.4070702@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Petlund wrote:
> +/* Determines whether this is a thin stream (which may suffer from
> + * increased latency). Used to trigger latency-reducing mechanisms.
> + */
> +static inline unsigned int tcp_stream_is_thin(const struct tcp_sock *tp)
> +{
> +	return tp->packets_out < 4;
> +}
> +
This bothers me a bit.  Having just looked at your Linux presentation,
and not (yet) read your papers, it seems much of your justification was
with 1 packet per RTT.  Here, you seem to be concentrating on 4, probably
because many implementations quickly ramp up to 4.

But there's a fair amount of experience showing that ramping to 4 is
problematic on congested paths, especially wireless networks.  Fast
retransmit in that case would be disastrous.

Once upon a time, I worked on a fair number of interactive games a decade
or so ago.  And agree that this can be a problem, although I've never
been a fan of turning off the Nagle algorithm.  My solution has always
been a heartbeat, rather than trying to shoehorn this into TCP.

Also, I've not seen any discussion on the end-to-end interest list.
