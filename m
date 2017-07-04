From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bridge: mdb: report complete_info ptr as
 not a kmemleak
Date: Tue, 04 Jul 2017 01:48:42 -0700 (PDT)
Message-ID: <20170704.014842.1942928249505987408.davem@davemloft.net>
References: <1499101594-22421-1-git-send-email-eduval@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: eduval@amazon.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1499101594-22421-1-git-send-email-eduval@amazon.com>
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

From: Eduardo Valentin <eduval@amazon.com>
Date: Mon, 3 Jul 2017 10:06:34 -0700

> We currently get the following kmemleak report:
 ...
> This patch flags the complete_info ptr object as not a leak as it will
> get freed when .complete_priv() is called,

We don't call .complete_priv().  We call .complete().

 for the br mdb case, it
> will be freed at br_mdb_complete().
> 
> Cc: stable <stable@vger.kernel.org> # v4.9+
> Reviewed-by: Vallish Vaidyeshwara <vallish@amazon.com>
> Signed-off-by: Eduardo Valentin <eduval@amazon.com>

I don't understand why kmemleak cannot see this.

We store the pointer globally when we do the switchdev_port_obv_add()
call and it should be able to see that.
