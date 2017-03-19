From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Sat, 18 Mar 2017 18:21:21 -0700 (PDT)
Message-ID: <20170318.182121.439615057765380575.davem@davemloft.net>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170318164759.GA23837@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, eric.dumazet@gmail.com, peterz@infradead.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, jmorris@namei.org,
	ishkamiel@gmail.com, kuznet@ms2.inr.ac.ru,
	akpm@linux-foundation.org, kaber@trash.net,
	elena.reshetova@intel.com, dwindsor@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170318164759.GA23837@gondor.apana.org.au>
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

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 19 Mar 2017 00:47:59 +0800

> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2017-03-17 at 07:42 +0000, Reshetova, Elena wrote:
>> 
>>> Should we then first measure the actual numbers to understand what we
>>> are talking here about? 
>>> I would be glad to do it if you suggest what is the correct way to do
>>> measurements here to actually reflect the real life use cases. 
>> 
>> How have these patches been tested in real life exactly ?
>> 
>> Can you quantify number of added cycles per TCP packet, where I expect
>> we have maybe 20 atomic operations in all layers ...
> 
> I completely agree.  I think this thing needs to default to the
> existing atomic_t behaviour.

I totally agree as well, the refcount_t facility as-is is unacceptable
for networking.
