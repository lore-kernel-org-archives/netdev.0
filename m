From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Wed, 21 Nov 2012 07:01:15 -0800
Message-ID: <1353510075.24807.24.camel@joe-AO722>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20121120115239.GA7955@dm> <1353448728.17819.33.camel@joe-AO722>
	 <20121120231930.GA27492@localhost> <1353454874.17819.41.camel@joe-AO722>
	 <1353490921.6559.40.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Whitcroft <apw@canonical.com>,
	David Rientjes <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353490921.6559.40.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-11-21 at 11:42 +0200, Eilon Greenstein wrote:
> On Tue, 2012-11-20 at 15:41 -0800, Joe Perches wrote:
> > On Tue, 2012-11-20 at 23:19 +0000, Andy Whitcroft wrote:
> > > On Tue, Nov 20, 2012 at 01:58:48PM -0800, Joe Perches wrote:
> > > 
> > > > +# check for multiple blank lines, warn only on the second one in a block
> > > > +		if ($rawline =~ /^.\s*$/ &&
> > > > +		    $prevrawline =~ /^.\s*$/ &&
> > > > +		    $linenr != $last_blank_linenr + 1) {
> > > > +			CHK("DOUBLE_EMPTY_LINE",
> > > > +			    "One blank line separating blocks is generally sufficient\n" . $herecurr);
> > > > +			$last_blank_linenr = $linenr;
> > > > +		}
> > > > +
> > > >  # check for line continuations in quoted strings with odd counts of "
> > > >  		if ($rawline =~ /\\$/ && $rawline =~ tr/"/"/ % 2) {
> > > >  			WARN("LINE_CONTINUATIONS",
> > > 
> > > Pretty sure that will fail with combination which have removed lines.
> > 
> > Not as far as I can tell.
> > Deleted lines followed by inserted lines seem
> > to work OK.
> > 
> > This check is located after the test that ensures
> > the current $line/$rawline is an insertion.
> > 
> 
> But you do not look at the next line, so you will miss something like
> that:
> 
> diff --git a/test.c b/test.c
> index e3c46d4..e1c6ffc 100644
> --- a/test.c
> +++ b/test.c
> @@ -15,7 +15,8 @@
>   * something
>   * something
>   * something
> - * next line was already empty */
> + * next line was already empty, but I'm adding another one now*/
> +

Hi Eilon.

Thanks for the test case.

That's true, but I'm OK with missing a few cases in the
search for simplicity as long as there aren't significant
false positives.

For instance the next test
# check for line continuations in quoted strings with odd counts of "
		if ($rawline =~ /\\$/ && $rawline =~ tr/"/"/ % 2) {
			WARN("LINE_CONTINUATIONS",

That fails if the rawline is:
	"\"" \
Does it matter much?  Probably not.
I suppose that test could be improved by using $line.

checkpatch isn't a perfect tool.  Given how it's constructed,
I doubt it ever could be.

No doubt you and Andy will find a better solution.
