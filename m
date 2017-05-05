From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] qlge: Avoid reading past end of buffer
Date: Fri, 5 May 2017 15:34:34 -0700
Message-ID: <20170505223434.GA19245@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com, linux-kernel@vger.kernel.org,
        Daniel Micay <danielmicay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using memcpy() from a string that is shorter than the length copied means
the destination buffer is being filled with arbitrary data from the kernel
rodata segment. Instead, use strncpy() which will fill the trailing bytes
with zeros.

This was found with the future CONFIG_FORTIFY_SOURCE feature.

Cc: Daniel Micay <danielmicay@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
index 829be21f97b2..28ea0af89aef 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
@@ -765,7 +765,7 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 		sizeof(struct mpi_coredump_global_header);
 	mpi_coredump->mpi_global_header.imageSize =
 		sizeof(struct ql_mpi_coredump);
-	memcpy(mpi_coredump->mpi_global_header.idString, "MPI Coredump",
+	strncpy(mpi_coredump->mpi_global_header.idString, "MPI Coredump",
 		sizeof(mpi_coredump->mpi_global_header.idString));
 
 	/* Get generic NIC reg dump */
@@ -1255,7 +1255,7 @@ static void ql_gen_reg_dump(struct ql_adapter *qdev,
 		sizeof(struct mpi_coredump_global_header);
 	mpi_coredump->mpi_global_header.imageSize =
 		sizeof(struct ql_reg_dump);
-	memcpy(mpi_coredump->mpi_global_header.idString, "MPI Coredump",
+	strncpy(mpi_coredump->mpi_global_header.idString, "MPI Coredump",
 		sizeof(mpi_coredump->mpi_global_header.idString));
 
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
