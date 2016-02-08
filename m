From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: 8 Feb 2016 15:12:34 -0500
Message-ID: <20160208201234.8569.qmail@ns.horizon.com>
Cc: mingo@kernel.org
To: David.Laight@ACULAB.COM, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight wrote:
> I'd need convincing that unrolling the loop like that gives any significant gain.
> You have a dependency chain on the carry flag so have delays between the 'adcq'
> instructions (these may be more significant than the memory reads from l1 cache).

If the carry chain is a bottleneck, on Broadwell+ (feature flag
X86_FEATURE_ADX), there are the ADCX and ADOX instructions, which use
separate flag bits for their carry chains and so can be interleaved.

I don't have such a machine to test on, but if someone who does
would like to do a little benchmarking, that would be an interesting
data point.

Unfortunately, that means yet another version of the main loop,
but if there's a significant benefit...
