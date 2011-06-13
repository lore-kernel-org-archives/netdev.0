From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 RFC 0/4] virtio and vhost-net capacity
	handling
Date: Mon, 13 Jun 2011 16:35:13 +0300
Message-ID: <20110613133513.GA29884@redhat.com>
References: <cover.1307029008.git.mst@redhat.com>
	<20110607160830.GB17581@redhat.com>
	<OFE36F9C2B.43D9DB04-ON652578AE.0048E1AB-652578AE.004A1462@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <OFE36F9C2B.43D9DB04-ON652578AE.0048E1AB-652578AE.004A1462-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2011 at 07:02:27PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote on 06/07/2011 09:38:30 PM:
> 
> > > This is on top of the patches applied by Rusty.
> > >
> > > Warning: untested. Posting now to give people chance to
> > > comment on the API.
> >
> > OK, this seems to have survived some testing so far,
> > after I dropped patch 4 and fixed build for patch 3
> > (build fixup patch sent in reply to the original).
> >
> > I'll be mostly offline until Sunday, would appreciate
> > testing reports.
> 
> Hi Michael,
> 
> I ran the latest patches with 1K I/O (guest->local host) and
> the results are (60 sec run for each test case):

Hi!
Did you apply this one:
[PATCHv2 RFC 4/4] Revert "virtio: make add_buf return capacity remaining"
?

It turns out that that patch has a bug and should be reverted,
only patches 1-3 should be applied.

Could you confirm please?


> ___________________/
> #sessions   BW%       SD%
> ______________________________
> 1           -25.6     47.0
> 2           -29.3     22.9
> 4              .8     1.6
> 8             1.6     0
> 16          -1.6      4.1
> 32          -5.3      2.1
> 48           11.3    -7.8
> 64          -2.8      .7
> 96          -6.2      .6
> 128         -10.6     12.7
> ______________________________
> BW: -4.8     SD: 5.4
> 
> I tested it again to see if the regression is fleeting (since
> the numbers vary quite a bit for 1K I/O even between guest->
> local host), but:
> 
> ______________________________
> #sessions  BW%     SD%
> ______________________________
> 1          14.0    -17.3
> 2          19.9    -11.1
> 4          7.9     -15.3
> 8          9.6     -13.1
> 16         1.2     -7.3
> 32        -.6      -13.5
> 48        -28.7     10.0
> 64        -5.7     -.7
> 96        -9.4     -8.1
> 128       -9.4      .7
> ______________________________
> BW: -3.7     SD: -2.0
> 
> 
> With 16K, there was an improvement in SD, but
> higher sessions seem to slightly degrade BW/SD:
> 
> ______________________________
> #sessions  BW%      SD%
> ______________________________
> 1          30.9    -25.0
> 2          16.5    -19.4
> 4         -1.3      7.9
> 8          1.4      6.2
> 16         3.9     -5.4
> 32         0        4.3
> 48        -.5        .1
> 64         32.1    -1.5
> 96        -2.1      23.2
> 128       -7.4      3.8
> ______________________________
> BW: 5.0          SD: 7.5
> 
> 
> Thanks,
> 
> - KK
