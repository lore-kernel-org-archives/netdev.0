From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 17:07:07 +0200
Message-ID: <1353424027.6559.15.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
 <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120144329.GE7955@dm>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Joe Perches" <joe@perches.com>,
	"David Rientjes" <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Andy Whitcroft" <apw@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121120144329.GE7955@dm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-20 at 14:43 +0000, Andy Whitcroft wrote:

> > > Also this fails if the fragment
> > > is at the top of the hunk emiting a perl warning.
> > 
> > I did not see this warning. Can you please share this example? I tried
> > adding a couple of empty lines at the beginning of a file and it seemed
> > to work just fine for me (using perl v5.14.2).lines
> 
> Ok, this is actually if it is at the bottom, not the top.  So if you
> have a range of lines newly added to the bottom of the file.  Leading to
> this warning:
> 
> Use of uninitialized value within @rawlines in pattern match (m//) at
> ../checkpatch/scripts/checkpatch.pl line 3586.

Oh... of course, I should have seen that. I did not check changes at the
end of the file.

What do you say about something like that (using nextline out of
rawlines only if it defined):
diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 21a9f5d..c0c610c 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3579,6 +3579,19 @@ sub process {
                        WARN("EXPORTED_WORLD_WRITABLE",
                             "Exporting world writable files is usually an error. Consider more restrictive permissions.
                }
+
+# check for double empty lines
+               if ($line =~ /^\+\s*$/) {
+                       my $nextline = "";
+                       if (defined($rawlines[$linenr])) {
+                               $nextline = $rawlines[$linenr];
+                       }
+                       if ($nextline =~ /^\s*$/ ||
+                           $prevline =~ /^\+?\s*$/ && $nextline !~ /^\+\s*$/) {
+                               CHK("DOUBLE_EMPTY_LINE",
+                                   "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
+                       }
+               }
        }
 


If you think it's appropriate, I will send a clean copy.

Thanks,
Eilon
