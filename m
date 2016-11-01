From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: ixgbe 4.4.6 detected crash
Date: Tue, 1 Nov 2016 11:40:52 -0700
Message-ID: <CAKgT0UdO8xazf5P_kKGnxHa8VjB8dLp9qpsX9q7Mp4WTFC8q7g@mail.gmail.com>
References: <CA+dKekAEc1YcXhDMYrRNHEJPO-sadjB4u0-8+vt51iOabx-C4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5795212555609550979=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Matias Vara <matiasevara@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CA+dKekAEc1YcXhDMYrRNHEJPO-sadjB4u0-8+vt51iOabx-C4g@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============5795212555609550979==
Content-Type: multipart/alternative; boundary=001a1144101afe62b6054041a991

--001a1144101afe62b6054041a991
Content-Type: text/plain; charset=UTF-8

On Tue, Nov 1, 2016 at 8:16 AM, Matias Vara <matiasevara@gmail.com> wrote:

> Hi everyone, I am facing an issue with the ixgbe 10G Network card version
> 4.4.6. I am in XenServer which is based on CentOS and the issue only appers
> on FCOE machines. I am getting the following message during crash:
>
> [2016-10-28 09:43:58 UTC] [ 68.789174] kernel BUG at
> /obj/RPM_BUILD_DIRECTORY/driver-intel-ixgbe-4.4.6/src/ixgbe_fcoe.c:440!
>
> Someone knows what is happening?To track this bug, I opened the ticket
> #543. Please go to the ticket for more details.
>
> Thanks in advance, Matias.


I just replied to your bug but I will reply here as well.

The 4.4 kernel has a bug that is fixed by the following commit:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.
git/commit/?id=224516b3a798

I would recommend back-porting it into your kernel and we probably need to
have this queued up for linux-stable as well.

>From what I can tell I overlooked adding the following which should have
probably been included in the original patch.
Fixes: a6e544b0a88b ("flow_dissector: Jump to exit code in
__skb_flow_dissect")

Thanks.

- Alex

--001a1144101afe62b6054041a991--


--===============5795212555609550979==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
--===============5795212555609550979==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5795212555609550979==--
