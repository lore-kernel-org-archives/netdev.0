From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ath10k: wmi: Convert use of 6 to ETH_ALEN
Date: Wed, 02 Oct 2013 21:56:01 -0700
Message-ID: <1380776161.2081.99.camel@joe-AO722>
References: <1380679480.2081.24.camel@joe-AO722>
	 <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
	 <1380696054.2081.35.camel@joe-AO722>
	 <CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>
	 <1380736969.2081.72.camel@joe-AO722>
	 <alpine.DEB.2.02.1310030034030.2162@localhost6.localdomain6>
	 <1380758954.2081.79.camel@joe-AO722> <1380760114.2081.81.camel@joe-AO722>
	 <1380771110.2081.89.camel@joe-AO722> <1380771551.2081.93.camel@joe-AO722>
	 <1380773924.19002.131.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev <netdev@vger.kernel.org>, ath10k@lists.infradead.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0152.hostedemail.com ([216.40.44.152]:53799 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757225Ab3JCE4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 00:56:05 -0400
In-Reply-To: <1380773924.19002.131.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 21:18 -0700, Eric Dumazet wrote:
> On Wed, 2013-10-02 at 20:39 -0700, Joe Perches wrote:
> > Use the appropriate define instead of 6.
[]
> I don't get it.
> Why leaving this then ?
> 
> struct wmi_mac_addr {
>         union {
>                 u8 addr[6];
>                 struct {
>                         u32 word0;
>                         u32 word1;
>                 } __packed;
>         } __packed;
> } __packed;

'cause I just did the ones I noticed around the memcpy/memset
grep pattern I used.

$ grep -rP --include=*.[ch] -n "\b(memset|memcpy)\s*\([^,]+,[^,]+,\s*6\s*\)" drivers/net

You're welcome to look for all the [6] uses and convert the
appropriate ones too.  Maybe use that eth_addr_t typedef.

$ git grep -E "\[\s*6\s*\]\s*;" drivers/net/
