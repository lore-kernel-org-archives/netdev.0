From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3 4/5] net-sysfs: add support for
	device-specific rx queue sysfs attributes
Date: Thu, 16 Jan 2014 19:42:32 +0000
Message-ID: <1389901352.11912.73.camel@bwh-desktop.uk.level5networks.com>
References: <1389865126-26225-1-git-send-email-mwdalton@google.com>
	<1389865126-26225-4-git-send-email-mwdalton@google.com>
	<1389898650.11912.65.camel@bwh-desktop.uk.level5networks.com>
	<CANJ5vP+nDgi7vWOd=RSuZ=NS5Z_txEkEsoYYm_33sFPh6rr=gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>, Eric
	Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vP+nDgi7vWOd=RSuZ=NS5Z_txEkEsoYYm_33sFPh6rr=gg@mail.gmail.com>
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

On Thu, 2014-01-16 at 11:07 -0800, Michael Dalton wrote:
> On Jan 16, 2014 at 10:57 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > Why write a loop when you can do:
> >         i = queue - dev->_rx;
> Good point, the loop approach was done in get_netdev_queue_index --
> I agree your fix is faster and simpler. I'll fix in next patchset.

It's simpler but we don't know if it's faster (and I don't believe that
matters for the current usage).

If one of these functions starts to be used in the data path, at that
point it could be worth optimising, e.g. by doing a test for queue 0 and
only then doing the pointer arithmetic with its implicit division.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
