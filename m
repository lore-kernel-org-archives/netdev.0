From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 10:45:32 -0700
Message-ID: <20091026104532.5c30c6b9@nehalam>
References: <200910252158.53921.opurdila@ixiacom.com>
	<200910261631.44666.opurdila@ixiacom.com>
	<4AE5B84E.8040505@gmail.com>
	<200910261752.51784.opurdila@ixiacom.com>
	<20091026095516.02f1cb49@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48443 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbZJZRpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 13:45:33 -0400
In-Reply-To: <20091026095516.02f1cb49@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another algorithm that scores well in my tests.

http://isthe.com/chongo/tech/comp/fnv/

Algorithm             Time       Ratio       Max   StdDev
string10             1.433267       1.00     39064   0.01
string_hash17        1.461422       1.00     39497   1.50
fnv1a                1.472216       1.00     39895   2.25
jhash_string         1.482494       1.00     39669   1.04


static unsigned int fnv32(const unsigned char *key, unsigned int len)
{
	uint32_t hval = 2166136261;
	unsigned int i;

	for (i = 0; i < len; i++) {
		hval ^= key[i];
		/* optimized multiply by 0x01000193 */
		hval += (hval<<1) + (hval<<4) + (hval<<7)
			+ (hval<<8) + (hval<<24);
	}

	return hval;
}
