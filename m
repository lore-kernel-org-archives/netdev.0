From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Subject: [PATCH v2 0/2] net: davinci_emac: Fix interrupt requests and error
	handling
Date: Mon, 24 Mar 2014 13:46:25 +0100
Message-ID: <ffba6fa2-5a11-41b0-a310-12250e104405@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        Florian Fainelli
	<f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jon Ringle <jon-7zJyie9iPacdnm+yROfE0A@public.gmane.org>,
        David Miller
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces+gld-davinci-linux-open-source=gmane.org-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

since commit 6892b41d9701283085b655c6086fb57a5d63fa47 (Linux 3.11) the
davinci_emac driver is broken. After doing ifconfig down, ifconfig up,
requesting the interrupts for the driver fails. The interface remains dead
until the board is rebooted.

The first patch in this patchset reverts commit
6892b41d9701283085b655c6086fb57a5d63fa47 partially and makes the driver
useable again.

During the work on the first patch, a number of bugs in the error handling
of the driver's ndo_open code were found. The second patch fixes these bugs.

I believe the first patch meets the rules for stable kernels, I therefore added
the stable tag to this patch. The second patch is just cleanup, the code
that is fixed by this patch is only executed in case of an error.

Best regards,
Christian

Changes for v2:
- Added a longer commit message to the second patch, explaining the problems
  more detailed.

Christian Riesch (2):
  net: davinci_emac: Replace devm_request_irq with request_irq
  net: davinci_emac: Fix rollback of emac_dev_open()

 drivers/net/ethernet/ti/davinci_cpdma.c |    4 +--
 drivers/net/ethernet/ti/davinci_emac.c  |   53 ++++++++++++++++++++++++-------
 2 files changed, 44 insertions(+), 13 deletions(-)

-- 
1.7.9.5
