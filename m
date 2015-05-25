From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: skip fdb add if the port
 shouldn't learn
Date: Sun, 24 May 2015 22:59:02 -0400 (EDT)
Message-ID: <20150524.225902.2017701461230237731.davem@davemloft.net>
References: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	wkok@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 21 May 2015 03:42:57 -0700

> From: Wilson Kok <wkok@cumulusnetworks.com>
> 
> Check in fdb_add_entry() if the source port should learn, similar
> check is used in br_fdb_update.
> Note that new fdb entries which are added manually or
> as local ones are still permitted.
> This patch has been tested by running traffic via a bridge port and
> switching the port's state, also by manually adding/removing entries
> from the bridge's fdb.
> 
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> Nik: Maybe it'd be better if we returned an error even though it
>      doesn't look necessary. I'm open to suggestions.

If you don't return an error, then rtnetlink.c is going to emit a
NEWNEIGH netlink message.  I seriously doubt we want that to happen.
