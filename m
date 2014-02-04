From: Cong Wang <cwang@twopensource.com>
Subject: Re: [bisected] Re: WARNING: at net/ipv4/devinet.c:1599
Date: Tue, 4 Feb 2014 10:08:48 -0800
Message-ID: <CAHA+R7Omv++NCg=nocVsW+tM=Zv_qCNhX1JjtFTuCzfz9B3Cig@mail.gmail.com>
References: <CAMuHMdVCeFek2LX0_AnA8zg_yYhXvzw19rH8OsqbWWb-rb9w-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVCeFek2LX0_AnA8zg_yYhXvzw19rH8OsqbWWb-rb9w-A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 4, 2014 at 6:19 AM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>
> Anyone with a clue?
>

Looks like we need:

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index ac2dff3..bdbf68b 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1443,7 +1443,8 @@ static size_t inet_nlmsg_size(void)
               + nla_total_size(4) /* IFA_LOCAL */
               + nla_total_size(4) /* IFA_BROADCAST */
               + nla_total_size(IFNAMSIZ) /* IFA_LABEL */
-              + nla_total_size(4);  /* IFA_FLAGS */
+              + nla_total_size(4)  /* IFA_FLAGS */
+              + nla_total_size(sizeof(struct ifa_cacheinfo)); /*
IFA_CACHEINFO */
 }

 static inline u32 cstamp_delta(unsigned long cstamp)
