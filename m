From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 3/6] vhost: switch to use vhost_add_used_n()
Date: Tue, 20 Aug 2013 10:36:11 +0800
Message-ID: <5212D61B.1010303@redhat.com>
References: <1376630190-5912-1-git-send-email-jasowang@redhat.com>
	<1376630190-5912-4-git-send-email-jasowang@redhat.com>
	<20130816095655.GB21821@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130816095655.GB21821@redhat.com>
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

On 08/16/2013 05:56 PM, Michael S. Tsirkin wrote:
> On Fri, Aug 16, 2013 at 01:16:27PM +0800, Jason Wang wrote:
>> > Let vhost_add_used() to use vhost_add_used_n() to reduce the code duplication.
>> > 
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> Does compiler inline it then?
> Reason I ask, last time I checked put_user inside vhost_add_used
> was much cheaper than copy_to_user inside vhost_add_used_n,
> so I wouldn't be surprised if this hurt performance.
> Did you check?
>

I run virtio_test but didn't see the difference.

Did you mean the might_fault() in __copy_to_user()? So how about switch
to use __put_user() if count is one in __vhost_add_used_n()?
