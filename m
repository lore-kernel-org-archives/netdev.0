From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Fix suboptimal fragment sizing for last fragment
Date: Thu, 2 Sep 2004 14:44:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902144436.2c8c1337.davem@redhat.com>
References: <4137681D.3000902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, herbert@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4137681D.3000902@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2004 20:36:13 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch always builds mtu sized fragments and truncates the previous
> fragment to a multiple of 8 bytes when allocating a new one. With the
> patch the dump looks like this:

Looks great Patrick, applied.

I see only one remaining possible improvement.  If the fraggap
area is paged data, we probably should try use page frags
in the new SKB if this split occurs in ip_append_page().
