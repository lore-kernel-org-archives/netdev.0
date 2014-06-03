From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PULL 2/2] vhost: replace rcu with mutex
Date: Tue, 03 Jun 2014 09:35:17 -0400
Message-ID: <538DCF15.4080904@gmail.com>
References: <1401744482-17764-1-git-send-email-mst@redhat.com>	<1401744482-17764-3-git-send-email-mst@redhat.com>
	<1401746280.3645.187.camel@edumazet-glaptop2.roam.corp.google.com>
	<538DC422.1050303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Paolo Bonzini <pbonzini@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <538DC422.1050303@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 06/03/2014 08:48 AM, Paolo Bonzini wrote:
> Il 02/06/2014 23:58, Eric Dumazet ha scritto:
>> This looks dubious
>>
>> What about using kfree_rcu() instead ?
> 
> It would lead to unbound allocation from userspace.
> 
>> translate_desc() still uses rcu_read_lock(), its not clear if the mutex
>> is really held.
> 
> Yes, vhost_get_vq_desc must be called with the vq mutex held.
> 
> The rcu_read_lock/unlock in translate_desc is unnecessary.
> 

If that's true, then does dev->memory really needs to be rcu protected?
It appears to always be read under mutex.

-vlad

> Paolo
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
