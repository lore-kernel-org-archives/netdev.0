From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx
	buffer size for improved performance
Date: Wed, 08 Jan 2014 10:44:37 -0800
Message-ID: <1389206677.31367.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<52CCEEF3.5070904@redhat.com>
	<CANJ5vP+btxgZg5kDq30KZTEXO7YBCL5TWoiRzjMqxnaA3Edkxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vP+btxgZg5kDq30KZTEXO7YBCL5TWoiRzjMqxnaA3Edkxw@mail.gmail.com>
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

On Wed, 2014-01-08 at 10:28 -0800, Michael Dalton wrote:
> Hi Jason,
> 
> On Tue, Jan 7, 2014 at 10:23 PM, Jason Wang <jasowang@redhat.com> wrote:
> > What's the reason that this extra space is not accounted for truesize?
> The initial rationale was that this extra space is due to
> internal fragmentation in the page frag allocator, but I agree with
> you -- this code should be changed and the extra space accounted for.
> Any internal fragmentation leading to a larger last packet allocated from
> the page should be reflected in the SKB truesize of the last packet.

Thats not a hard requirement.

Lets keep things simple and fast.

Correctness here is not mandatory, as long as we do not underestimate
truesize by a huge value like a factor of 10.

Hint :

When __netdev_alloc_frag() has to allocate a new page, because
remaining space in current page is too small, the lost hole is not
accounted to users of current page.
