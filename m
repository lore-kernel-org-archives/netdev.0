From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 6/7] r8169: add a new chip for RTL8106E
Date: Tue, 2 Apr 2013 10:59:29 +0800
Message-ID: <AB471B8BF00E49B38C3F20840B5B82A2@realtek.com.tw>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com> <1364824539-4156-6-git-send-email-hayeswang@realtek.com> <20130401222335.GC19335@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130401222335.GC19335@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, April 02, 2013 6:24 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next 6/7] r8169: add a new chip for RTL8106E
> 
> Hayes Wang <hayeswang@realtek.com> :
> [...]
> > - move rtl_set_rx_tx_desc_registers to avoid the tx/rx are enabled
> >   before setting desc registers.
> 
> This is a wholesale change for the 810x family.
> 
> Please explain why issuing rtl_set_rx_tx_desc_registers before writing
> ChipCmd is not enough and feed it through a standalone commit.
> 

According to the new initial flow of this new chip, the tx/rx would be enabled
in rtl_hw_start_8168g_2 function. And this function is run before
rtl_set_rx_tx_desc_registers. It would be a problem, so I move
rtl_set_rx_tx_desc_registers to make sure that the descriptor address would be
set before the tx/rx is enabled. It has no influence for the previous chips, and
I think the following new chips would base on the new flow.
 
Best Regards,
Hayes
