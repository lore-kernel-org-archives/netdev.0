From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: ethernet: marvell: sky2.c: Cleaning up missing
 null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 13:53:39 -0700
Message-ID: <20140915135339.0659f618@urahara>
References: <1410716023-16068-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<20140914190557.690183d2@urahara>
	<20140915.130721.589682835868904320.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rickard_strandqvist@spectrumdigital.se, mlindner@marvell.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140915.130721.589682835868904320.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2014 13:07:21 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sun, 14 Sep 2014 19:05:57 -0700
> 
> > On Sun, 14 Sep 2014 19:33:43 +0200
> > Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> wrote:
> > 
> >> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
> >> 
> >> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> >> ---
> >>  drivers/net/ethernet/marvell/sky2.c |    2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> 
> >> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> >> index dba48a5c..7053d38 100644
> >> --- a/drivers/net/ethernet/marvell/sky2.c
> >> +++ b/drivers/net/ethernet/marvell/sky2.c
> >> @@ -4907,7 +4907,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
> >>  	};
> >>  
> >>  	if (chipid >= CHIP_ID_YUKON_XL && chipid <= CHIP_ID_YUKON_OP_2)
> >> -		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
> >> +		strlcpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
> >>  	else
> >>  		snprintf(buf, sz, "(chip %#x)", chipid);
> >>  	return buf;
> > 
> > Useless and unnecessary since the list of names is right there.
> > Why not avoid the copy all together?
> > 
> > Subject: sky2: avoid strncpy
> > 
> > Don't use strncpy() since security thought police think it is bad.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> I think providing the buffer on the stack of the thread executing the
> probe is superior because it will allow enabling parallel probing
> in the future.
> 
> I don't think you have to change that aspect to achieve your goal
> of returning the const char * string when possible.

What is benefit of s/strncpy/strlcpy/ for known safe code?
Seems like more of the checkpatch police state.
