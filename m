From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PULL 2/2] vhost: replace rcu with mutex
Date: Tue, 03 Jun 2014 14:48:34 +0200
Message-ID: <538DC422.1050303@redhat.com>
References: <1401744482-17764-1-git-send-email-mst@redhat.com>	<1401744482-17764-3-git-send-email-mst@redhat.com>
	<1401746280.3645.187.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1401746280.3645.187.camel@edumazet-glaptop2.roam.corp.google.com>
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

Il 02/06/2014 23:58, Eric Dumazet ha scritto:
> This looks dubious
>
> What about using kfree_rcu() instead ?

It would lead to unbound allocation from userspace.

> translate_desc() still uses rcu_read_lock(), its not clear if the mutex
> is really held.

Yes, vhost_get_vq_desc must be called with the vq mutex held.

The rcu_read_lock/unlock in translate_desc is unnecessary.

Paolo
