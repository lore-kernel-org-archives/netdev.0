From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: mISDN: dsp_cmx.c: Cleaning up a define that is
 no longer available
Date: Fri, 06 Jun 2014 16:28:12 -0700 (PDT)
Message-ID: <20140606.162812.1842868056512941704.davem@davemloft.net>
References: <1402097131-10954-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402097131-10954-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sat,  7 Jun 2014 01:25:30 +0200

> Removes an ifdef that is no longer available,
> and that would cause a compile error if it was activated.
> 
> This was partly found using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

This indentation looks wrong, and if you scan up you'll see why.

A different set of CPP guards create the openning curly brace(s):

	/* PROCESS DATA (two members) */
#ifdef CMX_CONF_DEBUG
	if (0) {
#else
		if (members == 2) {
#endif

This is crazy, and deleting only the DSP_NEVER_DEFINED part makes it
even more confusing because less sophisticated code analysis tools and
editing mode will think that the braces are unbalanced now.

I'm not applying this, it makes things worse not better, sorry.
