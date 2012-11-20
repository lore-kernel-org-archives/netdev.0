From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 14:43:29 +0000
Message-ID: <20121120144329.GE7955@dm>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
 <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	David Rientjes <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2012 at 04:27:04PM +0200, Eilon Greenstein wrote:
> On Tue, 2012-11-20 at 11:52 +0000, Andy Whitcroft wrote:
> 
> Andy, thanks for reviewing this patch.
> 
> > On Sat, Nov 17, 2012 at 01:17:37PM +0200, Eilon Greenstein wrote:
> > > Changes from previous attempt:
> > > - Use CHK instead of WARN
> > > - Issue only one warning per empty lines block
> > > 
> > > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > > ---
> > >  scripts/checkpatch.pl |    8 ++++++++
> > >  1 file changed, 8 insertions(+)
> > > 
> > > diff --git a/scripts/checkpatch.pl b/scripts/linescheckpatch.pl
> > > index 21a9f5d..13d264f 100755
> > > --- a/scripts/checkpatch.pl
> > > +++ b/scripts/checkpatch.pl
> > > @@ -3579,6 +3579,14 @@ sub process {
> > >  			WARN("EXPORTED_WORLD_WRITABLE",
> > >  			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
> > >  		}
> > > +
> > > +# check for double empty lines
> > > +		if ($line =~ /^\+\s*$/ &&
> > > +		    ($rawlines[$linenr] =~ /^\s*$/ ||
> > > +		     $prevline =~ /^\+?\s*$/ && $rawlines[$linenr] !~ /^\+\s*$/)) {
> > > +			CHK("DOUBLE_EMPTY_LINE",
> > > +			    "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> > > +		}
> > >  	}
> > >  
> > >  	# If we have no input at all, then there is nothing to report on
> > 
> > In your previous version you indicated you would be emiting one per group
> > of lines, I do not see how this does that.
> 
> This is what I'm testing:
> Only if the current line is a new blank line and:
> 	if the next line is empty but not newly added (this is the part that
> will make sure we get only one warning for a bunch of new lines - only
> the last newly added line will hit this condition)
> or
> 	if the previous line was empty (either new empty line or existing empty
> line) and the next line is not a new empty line (so we will issue just
> one warning).
> 
> I tested it on few examples, and did not see a problem. Can you share an
> example where it issues more than a single warning for a newly
> introduced consecutive new lines?

No indeed.  That was testing failure on my behalf.
> 
> > Also this fails if the fragment
> > is at the top of the hunk emiting a perl warning.
> 
> I did not see this warning. Can you please share this example? I tried
> adding a couple of empty lines at the beginning of a file and it seemed
> to work just fine for me (using perl v5.14.2).lines

Ok, this is actually if it is at the bottom, not the top.  So if you
have a range of lines newly added to the bottom of the file.  Leading to
this warning:

Use of uninitialized value within @rawlines in pattern match (m//) at
../checkpatch/scripts/checkpatch.pl line 3586.

-apw
