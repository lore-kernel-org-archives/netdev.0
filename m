From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Fix crash on big-endian systems during scan
Date: Mon, 17 Apr 2006 11:36:43 -0400
Message-ID: <1145288203.2649.3.camel@localhost.localdomain>
References: <20060414215911.17273.40460.stgit@dv.roinet.com>
	 <20060417010602.GL9551@jm.kir.nu> <20060417132105.GF5042@tuxdriver.com>
	 <1145284443.2212.5.camel@localhost.localdomain>
	 <20060417144541.GK5042@tuxdriver.com>
	 <1145286089.2649.0.camel@localhost.localdomain>
	 <20060417151659.GL5042@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com,
	Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:10665 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751130AbWDQPib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 11:38:31 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060417151659.GL5042@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-17 at 11:17 -0400, John W. Linville wrote:
> On Mon, Apr 17, 2006 at 11:01:29AM -0400, Dan Williams wrote:
> > On Mon, 2006-04-17 at 10:45 -0400, John W. Linville wrote:
> > > On Mon, Apr 17, 2006 at 10:34:03AM -0400, Dan Williams wrote:
> > > 
> > > > Pavel posted to netdev originally on Friday April 14th with the patch
> > > > included in the email, with the title "[PATCH] Fix crash on big-endian
> > > > systems during scan"...
> > > > 
> > > > http://www.spinics.net/lists/netdev/msg03023.html
> > > > 
> > > > Sure you don't have it somewhere?  If not, I'm sure somebody can
> > > > resend...
> > > 
> > > I must have fat-fingered a delete...sorry!
> > > 
> > > A repost would be most welcome...
> > 
> > I think Pavel just resent the patch with a "(repost)" at the end of the
> > subject line.
> 
> Hmmm...Randy Dunlap said offline that he had reposted, but I haven't
> seen one from him either...is it a big patch?

Two liner...

From: Pavel Roskin <proski@gnu.org>

The original code was doing arithmetics on a little-endian value.
Reported by Stelios Koroneos <stelios@stelioscellar.com>

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/hostap/hostap_ioctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 8b37e82..8399de5 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1860,7 +1860,7 @@ static char * __prism2_translate_scan(lo
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
 	if (scan) {
-		chan = scan->chid;
+		chan = le16_to_cpu(scan->chid);
 	} else if (bss) {
 		chan = bss->chan;
 	} else {
@@ -1868,7 +1868,7 @@ static char * __prism2_translate_scan(lo
 	}
 
 	if (chan > 0) {
-		iwe.u.freq.m = freq_list[le16_to_cpu(chan - 1)] * 100000;
+		iwe.u.freq.m = freq_list[chan - 1] * 100000;
 		iwe.u.freq.e = 1;
 		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
 						  IW_EV_FREQ_LEN);




