From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: RE: why get different number of MSI-X vector for broadcom bnx2x
 every time
Date: Fri, 14 May 2010 20:12:56 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C9@MILEXCH2.ds.jdsu.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497DED2BE@MILEXCH2.ds.jdsu.net>,<2DFD360E328B3941911E6D28B085D990107B83BB47@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Dmitry Kravkov <dmitry@broadcom.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og106.obsmtp.com ([64.18.2.165]:44899 "HELO
	exprod7og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751787Ab0EODNv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 23:13:51 -0400
In-Reply-To: <2DFD360E328B3941911E6D28B085D990107B83BB47@SJEXCHCCR01.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


hi Dmitry
the system,is the kernel(2.6.27) or the hardware?
thanks!
jon
________________________________________
From: Dmitry Kravkov [dmitry@broadcom.com]
Sent: Saturday, May 15, 2010 4:02 AM
To: Jon Zhou; netdev
Subject: RE: why get different number of MSI-X vector for broadcom bnx2x every time

Hi

Your system (from the log below) allowed bnx2x to use only 4 MSI-X vectors instead of 16 required by the driver.

Regards,
Dmitry

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Jon Zhou
Sent: Friday, May 14, 2010 11:02 AM
To: netdev
Subject: why get different number of MSI-X vector for broadcom bnx2x every time

hi there:

bnx2x_enable_msix :

...
rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
                             BNX2X_NUM_QUEUES(bp) + offset);

        /*
         * reconfigure number of tx/rx queues according to available
         * MSI-X vectors
         */
        if (rc >= BNX2X_MIN_MSIX_VEC_CNT) {
                /* vectors available for FP */
                int fp_vec = rc - BNX2X_MSIX_VEC_FP_START;


sometimes I can run up the driver with 4 queues but most of time I can only get 2 queues
why?

May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_set_num_queues:8053(eth5)]set number of queues to 15
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7544(eth5)]msix_table[0].entry = 0 (slowpath)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7549(eth5)]msix_table[1].entry = 1 (CNIC)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[2].entry = 2 (fastpath #0)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[3].entry = 3 (fastpath #1)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[4].entry = 4 (fastpath #2)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[5].entry = 5 (fastpath #3)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[6].entry = 6 (fastpath #4)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[7].entry = 7 (fastpath #5)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[8].entry = 8 (fastpath #6)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[9].entry = 9 (fastpath #7)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[10].entry = 10 (fastpath #8)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[11].entry = 11 (fastpath #9)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[12].entry = 12 (fastpath #10)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[13].entry = 13 (fastpath #11)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[14].entry = 14 (fastpath #12)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[15].entry = 15 (fastpath #13)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7556(eth5)]msix_table[16].entry = 16 (fastpath #14)
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7571(eth5)]Trying to use less MSI-X vectors: 4
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_enable_msix:7584(eth5)]New queue configuration set: 2
May 14 01:40:16 ibm-bc-54 kernel: bnx2x: eth5: using MSI-X  IRQs: sp 4321  fp[0] 4319 ... fp[1] 4318
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_nic_init:6067(eth5)]queue[0]:  bnx2x_init_sb(ffff8803e6810780,ffff8803f9c4f000)  cl_id 0  sb 1  cos 0
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_nic_init:6067(eth5)]queue[1]:  bnx2x_init_sb(ffff8803e6810780,ffff8803fb006000)  cl_id 1  sb 2  cos 0
May 14 01:40:16 ibm-bc-54 kernel: [bnx2x_init_rx_rings:5305(eth5)]mtu 1500  rx_buf_size 1650

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html