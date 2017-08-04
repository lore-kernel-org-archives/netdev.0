From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 0/6] In-kernel QMI handling
Date: Fri,  4 Aug 2017 07:59:32 -0700
Message-ID: <20170804145938.25427-1-bjorn.andersson@linaro.org>
Cc: linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series starts by moving the common definitions of the QMUX protocol to the
uapi header, as they are shared with clients - both in kernel and userspace.

This series then introduces in-kernel helper functions for aiding the handling
of QMI encoded messages in the kernel. QMI encoding is a wire-format used in
exchanging messages between the majority of QRTR clients and services.

It then adds an abstractions to reduce the duplication of common code in
drivers that needs to query the name server and send and receive encoded
messages to a remote service.

Finally it introduces a sample implementation for showing QRTR and the QMI
helpers in action. The sample device instantiates in response to finding the
"test service" and implements the "test protocol".

Bjorn Andersson (6):
  net: qrtr: Invoke sk_error_report() after setting sk_err
  net: qrtr: Move constants to header file
  net: qrtr: Add control packet definition to uapi
  soc: qcom: Introduce QMI encoder/decoder
  soc: qcom: Introduce QMI helpers
  samples: Introduce Qualcomm QRTR sample client

 drivers/soc/qcom/Kconfig          |   8 +
 drivers/soc/qcom/Makefile         |   3 +
 drivers/soc/qcom/qmi_encdec.c     | 812 ++++++++++++++++++++++++++++++++++++++
 drivers/soc/qcom/qmi_interface.c  | 540 +++++++++++++++++++++++++
 include/linux/soc/qcom/qmi.h      | 249 ++++++++++++
 include/uapi/linux/qrtr.h         |  35 ++
 net/qrtr/qrtr.c                   |  16 +-
 samples/Kconfig                   |   8 +
 samples/Makefile                  |   2 +-
 samples/qrtr/Makefile             |   1 +
 samples/qrtr/qrtr_sample_client.c | 603 ++++++++++++++++++++++++++++
 11 files changed, 2261 insertions(+), 16 deletions(-)
 create mode 100644 drivers/soc/qcom/qmi_encdec.c
 create mode 100644 drivers/soc/qcom/qmi_interface.c
 create mode 100644 include/linux/soc/qcom/qmi.h
 create mode 100644 samples/qrtr/Makefile
 create mode 100644 samples/qrtr/qrtr_sample_client.c

-- 
2.12.0
