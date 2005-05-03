From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [RTNETLINK] Fix RTM_MAX to represent the maximum
 valid message type
Date: Tue, 3 May 2005 14:27:40 -0700
Message-ID: <20050503142740.345925ea.davem@davemloft.net>
References: <20050430195058.GC577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050430195058.GC577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Apr 2005 21:50:58 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> RTM_MAX is currently set to the maximum reserverd message type plus one
> thus being the cause of two bugs for new types being assigned a) given the
> new family registers only the NEW command in its reserved block the array
> size for per family entries is calculated one entry short and b) given the
> new family registers all commands RTM_MAX would point to the first entry
> of the block following this one and the rtnetlink receive path would accept
> a message type for a nonexisting family.
> 
> This patch changes RTM_MAX to point to the maximum valid message type
> by aligning it to the start of the next block and subtracting one.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Excellent observation.  The fact that we encode the "modifies state"
in the low bits of the RTM_* numbers has always been a source of
obscure bugs and hard to track down errors.

Patch applied, thanks.
