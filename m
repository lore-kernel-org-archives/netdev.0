From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Oops with CONFIG_VMAP_STCK and bond device + virtio-net
Date: Tue, 6 Dec 2016 21:58:56 -0800
Message-ID: <CAM_iQpXDHuJDXtBU=-sLZuo2O9HeVnWTOFeuHdf0s29zBFMTGw@mail.gmail.com>
References: <bd4c37d9-9724-4c2a-8f0f-45b86fb5cb7f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	=?UTF-8?Q?Zbigniew_J=C4=99drzejewski=2DSzmek?= <zbyszek@in.waw.pl>
To: Laura Abbott <labbott@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <bd4c37d9-9724-4c2a-8f0f-45b86fb5cb7f@redhat.com>
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

On Mon, Dec 5, 2016 at 3:53 PM, Laura Abbott <labbott@redhat.com> wrote:
> This looks like an issue with CONFIG_VMAP_STACK since bond_enslave uses
> struct sockaddr from the stack and virtnet_set_mac_address calls
> sg_init_one which triggers BUG_ON(!virt_addr_valid(buf));
>
> I know there have been a lot of CONFIG_VMAP_STACK fixes around but I
> didn't find this one reported yet.

Fixed by:

commit e37e2ff350a321ad9c36b588e76f34fbba305be6
Author: Andy Lutomirski <luto@kernel.org>
Date:   Mon Dec 5 18:10:58 2016 -0800

    virtio-net: Fix DMA-from-the-stack in virtnet_set_mac_address()
