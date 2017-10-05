From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 0/7] net: qrtr: Fixes and support receiving version 2 packets
Date: Wed,  4 Oct 2017 20:50:58 -0700
Message-ID: <20171005035105.14677-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the latest Qualcomm platforms remote processors are sending packets with
version 2 of the message header. This series starts off with some fixes and
then refactors the qrtr code to support receiving messages of both version 1
and version 2.

As all remotes are backwards compatible transmitted packets continues to be
send as version 1, but some groundwork has been done to make this a per-link
property.

Bjorn Andersson (7):
  net: qrtr: Invoke sk_error_report() after setting sk_err
  net: qrtr: Move constants to header file
  net: qrtr: Add control packet definition to uapi
  net: qrtr: Pass source and destination to enqueue functions
  net: qrtr: Clean up control packet handling
  net: qrtr: Use sk_buff->cb in receive path
  net: qrtr: Support decoding incoming v2 packets

 include/uapi/linux/qrtr.h |  35 +++++
 net/qrtr/qrtr.c           | 377 +++++++++++++++++++++++++---------------------
 2 files changed, 241 insertions(+), 171 deletions(-)

-- 
2.12.0
