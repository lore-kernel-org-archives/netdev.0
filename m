From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: fix a possible dst leakage in
 ndisc_send_redirect()
Date: Tue, 3 Feb 2004 09:18:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203091841.2804a29c.davem@redhat.com>
References: <20040203.162754.96958174.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040203.162754.96958174.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Feb 2004 16:27:54 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> D: fix a dst leakage in error path in ndisc_send_redirect().

Applied.  An eventual cleanup of this function would be to consolidate
all of these paths into a single:

dst_out:
	dst_release(dst);
	return;

near the end of the function that all these spots can jump to.

But it's not so important.
