From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 10/10] ixgb: White space corrections
Date: Fri, 29 Oct 2004 05:13:25 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290505000.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb_ee.c netdev-2.6/drivers/net/ixgb.new/ixgb_ee.c
--- netdev-2.6/drivers/net/ixgb/ixgb_ee.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_ee.c	2004-10-15 13:15:44.000000000 -0700
@@ -32,7 +32,8 @@
 static uint16_t ixgb_shift_in_bits(struct ixgb_hw *hw);
 
 static void ixgb_shift_out_bits(struct ixgb_hw *hw,
-				uint16_t data, uint16_t count);
+				uint16_t data,
+				uint16_t count);
 static void ixgb_standby_eeprom(struct ixgb_hw *hw);
 
 static boolean_t ixgb_wait_eeprom_command(struct ixgb_hw *hw);
@@ -45,7 +46,9 @@ static void ixgb_cleanup_eeprom(struct i
  * hw - Struct containing variables accessed by shared code
  * eecd_reg - EECD's current value
  *****************************************************************************/
-static void ixgb_raise_clock(struct ixgb_hw *hw, uint32_t * eecd_reg)
+static void
+ixgb_raise_clock(struct ixgb_hw *hw,
+		  uint32_t *eecd_reg)
 {
 	/* Raise the clock input to the EEPROM (by setting the SK bit), and then
 	 *  wait 50 microseconds.
@@ -62,7 +63,9 @@ static void ixgb_raise_clock(struct ixgb
  * hw - Struct containing variables accessed by shared code
  * eecd_reg - EECD's current value
  *****************************************************************************/
-static void ixgb_lower_clock(struct ixgb_hw *hw, uint32_t * eecd_reg)
+static void
+ixgb_lower_clock(struct ixgb_hw *hw,
+		  uint32_t *eecd_reg)
 {
 	/* Lower the clock input to the EEPROM (by clearing the SK bit), and then
 	 * wait 50 microseconds.
@@ -81,7 +82,9 @@ static void ixgb_lower_clock(struct ixgb
  * count - number of bits to shift out
  *****************************************************************************/
 static void
-ixgb_shift_out_bits(struct ixgb_hw *hw, uint16_t data, uint16_t count)
+ixgb_shift_out_bits(struct ixgb_hw *hw,
+			 uint16_t data,
+			 uint16_t count)
 {
 	uint32_t eecd_reg;
 	uint32_t mask;
@@ -101,7 +101,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw, 
 		 */
 		eecd_reg &= ~IXGB_EECD_DI;
 
-		if (data & mask)
+		if(data & mask)
 			eecd_reg |= IXGB_EECD_DI;
 
 		IXGB_WRITE_REG(hw, EECD, eecd_reg);
@@ -113,7 +120,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw, 
 
 		mask = mask >> 1;
 
-	} while (mask);
+	} while(mask);
 
 	/* We leave the "DI" bit set to "0" when we leave this routine. */
 	eecd_reg &= ~IXGB_EECD_DI;
@@ -126,7 +133,8 @@ ixgb_shift_out_bits(struct ixgb_hw *hw, 
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static uint16_t ixgb_shift_in_bits(struct ixgb_hw *hw)
+static uint16_t
+ixgb_shift_in_bits(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 	uint32_t i;
@@ -144,14 +152,14 @@ static uint16_t ixgb_shift_in_bits(struc
 	eecd_reg &= ~(IXGB_EECD_DO | IXGB_EECD_DI);
 	data = 0;
 
-	for (i = 0; i < 16; i++) {
+	for(i = 0; i < 16; i++) {
 		data = data << 1;
 		ixgb_raise_clock(hw, &eecd_reg);
 
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
 		eecd_reg &= ~(IXGB_EECD_DI);
-		if (eecd_reg & IXGB_EECD_DO)
+		if(eecd_reg & IXGB_EECD_DO)
 			data |= 1;
 
 		ixgb_lower_clock(hw, &eecd_reg);
@@ -168,7 +176,8 @@ static uint16_t ixgb_shift_in_bits(struc
  * Lowers EEPROM clock. Clears input pin. Sets the chip select pin. This
  * function should be called before issuing a command to the EEPROM.
  *****************************************************************************/
-static void ixgb_setup_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_setup_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -189,7 +198,8 @@ static void ixgb_setup_eeprom(struct ixg
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_standby_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_standby_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -222,7 +232,8 @@ static void ixgb_standby_eeprom(struct i
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_clock_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_clock_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -245,7 +256,8 @@ static void ixgb_clock_eeprom(struct ixg
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_cleanup_eeprom(struct ixgb_hw *hw)
+static void
+ixgb_cleanup_eeprom(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 
@@ -270,7 +268,8 @@ static void ixgb_cleanup_eeprom(struct i
  *      TRUE: EEPROM data pin is high before timeout.
  *      FALSE:  Time expired.
  *****************************************************************************/
-static boolean_t ixgb_wait_eeprom_command(struct ixgb_hw *hw)
+static boolean_t
+ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 {
 	uint32_t eecd_reg;
 	uint32_t i;
@@ -284,10 +297,10 @@ static boolean_t ixgb_wait_eeprom_comman
 	 * signal that the command has been completed by raising the DO signal.
 	 * If DO does not go high in 10 milliseconds, then error out.
 	 */
-	for (i = 0; i < 200; i++) {
+	for(i = 0; i < 200; i++) {
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
-		if (eecd_reg & IXGB_EECD_DO)
+		if(eecd_reg & IXGB_EECD_DO)
 			return (TRUE);
 
 		udelay(50);
@@ -309,15 +322,16 @@ static boolean_t ixgb_wait_eeprom_comman
  *  TRUE: Checksum is valid
  *  FALSE: Checksum is not valid.
  *****************************************************************************/
-boolean_t ixgb_validate_eeprom_checksum(struct ixgb_hw * hw)
+boolean_t
+ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 {
 	uint16_t checksum = 0;
 	uint16_t i;
 
-	for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
+	for(i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
-	if (checksum == (uint16_t) EEPROM_SUM)
+	if(checksum == (uint16_t) EEPROM_SUM)
 		return (TRUE);
 	else
 		return (FALSE);
@@ -331,12 +345,13 @@ boolean_t ixgb_validate_eeprom_checksum(
  * Sums the first 63 16 bit words of the EEPROM. Subtracts the sum from 0xBABA.
  * Writes the difference to word offset 63 of the EEPROM.
  *****************************************************************************/
-void ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
+void
+ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
 {
 	uint16_t checksum = 0;
 	uint16_t i;
 
-	for (i = 0; i < EEPROM_CHECKSUM_REG; i++)
+	for(i = 0; i < EEPROM_CHECKSUM_REG; i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
 	checksum = (uint16_t) EEPROM_SUM - checksum;
@@ -356,7 +371,10 @@ void ixgb_update_eeprom_checksum(struct 
  * EEPROM will most likely contain an invalid checksum.
  *
  *****************************************************************************/
-void ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t offset, uint16_t data)
+void
+ixgb_write_eeprom(struct ixgb_hw *hw,
+				   uint16_t offset,
+				   uint16_t data)
 {
 	/*  Prepare the EEPROM for writing  */
 	ixgb_setup_eeprom(hw);
@@ -404,7 +422,9 @@ void ixgb_write_eeprom(struct ixgb_hw *h
  * Returns:
  *  The 16-bit value read from the eeprom
  *****************************************************************************/
-uint16_t ixgb_read_eeprom(struct ixgb_hw * hw, uint16_t offset)
+uint16_t
+ixgb_read_eeprom(struct ixgb_hw *hw,
+				  uint16_t offset)
 {
 	uint16_t data;
 
@@ -437,7 +437,8 @@ uint16_t ixgb_read_eeprom(struct ixgb_hw
  *      TRUE: if eeprom read is successful
  *      FALSE: otherwise.
  *****************************************************************************/
-boolean_t ixgb_get_eeprom_data(struct ixgb_hw * hw)
+boolean_t
+ixgb_get_eeprom_data(struct ixgb_hw *hw)
 {
 	uint16_t i;
 	uint16_t checksum = 0;
@@ -448,7 +448,7 @@ boolean_t ixgb_get_eeprom_data(struct ix
 	ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	DEBUGOUT("ixgb_ee: Reading eeprom data\n");
-	for (i = 0; i < IXGB_EEPROM_SIZE; i++) {
+	for(i=0; i < IXGB_EEPROM_SIZE ; i++) {
 		uint16_t ee_data;
 		ee_data = ixgb_read_eeprom(hw, i);
 		checksum += ee_data;
@@ -463,10 +464,10 @@ boolean_t ixgb_get_eeprom_data(struct ix
 	if ((ee_map->init_ctrl_reg_1 & le16_to_cpu(EEPROM_ICW1_SIGNATURE_MASK))
 	    != le16_to_cpu(EEPROM_ICW1_SIGNATURE_VALID)) {
 		DEBUGOUT("ixgb_ee: Signature invalid.\n");
-		return (FALSE);
+		return(FALSE);
 	}
 
-	return (TRUE);
+	return(TRUE);
 }
 
 /******************************************************************************
@@ -479,12 +480,13 @@ boolean_t ixgb_get_eeprom_data(struct ix
  *      TRUE: eeprom signature was good and the eeprom read was successful
  *      FALSE: otherwise.
  ******************************************************************************/
-static boolean_t ixgb_check_and_get_eeprom_data(struct ixgb_hw *hw)
+static boolean_t
+ixgb_check_and_get_eeprom_data (struct ixgb_hw* hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	if ((ee_map->init_ctrl_reg_1 & le16_to_cpu(EEPROM_ICW1_SIGNATURE_MASK))
-	    == le16_to_cpu(EEPROM_ICW1_SIGNATURE_VALID)) {
+		== le16_to_cpu(EEPROM_ICW1_SIGNATURE_VALID)) {
 		return (TRUE);
 	} else {
 		return ixgb_get_eeprom_data(hw);
@@ -500,15 +503,16 @@ static boolean_t ixgb_check_and_get_eepr
  * Returns:
  *          Word at indexed offset in eeprom, if valid, 0 otherwise.
  ******************************************************************************/
-uint16_t ixgb_get_eeprom_word(struct ixgb_hw * hw, uint16_t index)
+uint16_t
+ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index)
 {
 
 	if ((index < IXGB_EEPROM_SIZE) &&
-	    (ixgb_check_and_get_eeprom_data(hw) == TRUE)) {
-		return (hw->eeprom[index]);
+	    (ixgb_check_and_get_eeprom_data (hw) == TRUE)) {
+	   	return(hw->eeprom[index]);
 	}
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -519,7 +503,9 @@ 
  *
  * Returns: None.
  ******************************************************************************/
-void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t * mac_addr)
+void
+ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
+			uint8_t *mac_addr)
 {
 	int i;
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
@@ -526,7 +503,7 @@ 
 
 	DEBUGFUNC("ixgb_get_ee_mac_addr");
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE) {
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE) {
 		for (i = 0; i < IXGB_ETH_LENGTH_OF_ADDRESS; i++) {
 			mac_addr[i] = ee_map->mac_addr[i];
 			DEBUGOUT2("mac(%d) = %.2X\n", i, mac_addr[i]);
@@ -542,14 +546,15 @@ void ixgb_get_ee_mac_addr(struct ixgb_hw
  * Returns:
  *          compatibility flags if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_compatibility(struct ixgb_hw *hw)
+uint16_t
+ixgb_get_ee_compatibility(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->compatibility);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->compatibility);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -560,13 +564,14 @@ uint16_t ixgb_get_ee_compatibility(struc
  * Returns:
  *          PBA number if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint32_t ixgb_get_ee_pba_number(struct ixgb_hw * hw)
+uint32_t
+ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG])
-			| (le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG]) << 16));
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(le16_to_cpu(hw->eeprom[EEPROM_PBA_1_2_REG]) |
+			(le16_to_cpu(hw->eeprom[EEPROM_PBA_3_4_REG])<<16));
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -577,14 +581,15 @@ uint32_t ixgb_get_ee_pba_number(struct i
  * Returns:
  *          Initialization Control Word 1 if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_init_ctrl_reg_1(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_init_ctrl_reg_1(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->init_ctrl_reg_1);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->init_ctrl_reg_1);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -595,14 +599,15 @@ uint16_t ixgb_get_ee_init_ctrl_reg_1(str
  * Returns:
  *          Initialization Control Word 2 if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_init_ctrl_reg_2(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_init_ctrl_reg_2(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->init_ctrl_reg_2);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->init_ctrl_reg_2);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -613,14 +617,15 @@ uint16_t ixgb_get_ee_init_ctrl_reg_2(str
  * Returns:
  *          Subsystem Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_subsystem_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_subsystem_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->subsystem_id);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->subsystem_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -631,14 +635,15 @@ uint16_t ixgb_get_ee_subsystem_id(struct
  * Returns:
  *          Sub Vendor Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_subvendor_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_subvendor_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->subvendor_id);
+	if (ixgb_check_and_get_eeprom_data (hw) == TRUE)
+	   return(ee_map->subvendor_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -649,14 +653,15 @@ uint16_t ixgb_get_ee_subvendor_id(struct
  * Returns:
  *          Device Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_device_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_device_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->device_id);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->device_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -667,14 +671,15 @@ uint16_t ixgb_get_ee_device_id(struct ix
  * Returns:
  *          Device Id if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_vendor_id(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_vendor_id(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->vendor_id);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->vendor_id);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -685,14 +689,15 @@ uint16_t ixgb_get_ee_vendor_id(struct ix
  * Returns:
  *          SDP Register if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint16_t ixgb_get_ee_swdpins_reg(struct ixgb_hw * hw)
+uint16_t
+ixgb_get_ee_swdpins_reg(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->swdpins_reg);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->swdpins_reg);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -703,14 +707,15 @@ uint16_t ixgb_get_ee_swdpins_reg(struct 
  * Returns:
  *          D3 Power Management Bits if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint8_t ixgb_get_ee_d3_power(struct ixgb_hw * hw)
+uint8_t
+ixgb_get_ee_d3_power(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->d3_power);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->d3_power);
 
-	return (0);
+	return(0);
 }
 
 /******************************************************************************
@@ -721,12 +725,13 @@ uint8_t ixgb_get_ee_d3_power(struct ixgb
  * Returns:
  *          D0 Power Management Bits if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint8_t ixgb_get_ee_d0_power(struct ixgb_hw * hw)
+uint8_t
+ixgb_get_ee_d0_power(struct ixgb_hw *hw)
 {
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
-	if (ixgb_check_and_get_eeprom_data(hw) == TRUE)
-		return (ee_map->d0_power);
+	if(ixgb_check_and_get_eeprom_data(hw) == TRUE)
+		return(ee_map->d0_power);
 
-	return (0);
+	return(0);
 }
diff -up netdev-2.6/drivers/net/ixgb/ixgb_ee.h netdev-2.6/drivers/net/ixgb.new/ixgb_ee.h
--- netdev-2.6/drivers/net/ixgb/ixgb_ee.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_ee.h	2004-10-15 13:15:49.000000000 -0700
@@ -29,35 +29,35 @@
 #ifndef _IXGB_EE_H_
 #define _IXGB_EE_H_
 
-#define IXGB_EEPROM_SIZE    64	/* Size in words */
+#define IXGB_EEPROM_SIZE	64   /* Size in words */
 
 #define IXGB_ETH_LENGTH_OF_ADDRESS   6
 
 /* EEPROM Commands */
-#define EEPROM_READ_OPCODE  0x6	/* EERPOM read opcode */
-#define EEPROM_WRITE_OPCODE 0x5	/* EERPOM write opcode */
-#define EEPROM_ERASE_OPCODE 0x7	/* EERPOM erase opcode */
-#define EEPROM_EWEN_OPCODE  0x13	/* EERPOM erase/write enable */
-#define EEPROM_EWDS_OPCODE  0x10	/* EERPOM erast/write disable */
+#define EEPROM_READ_OPCODE  0x6  /* EERPOM read opcode */
+#define EEPROM_WRITE_OPCODE 0x5  /* EERPOM write opcode */
+#define EEPROM_ERASE_OPCODE 0x7  /* EERPOM erase opcode */
+#define EEPROM_EWEN_OPCODE  0x13 /* EERPOM erase/write enable */
+#define EEPROM_EWDS_OPCODE  0x10 /* EERPOM erase/write disable */
 
 /* EEPROM MAP (Word Offsets) */
-#define EEPROM_IA_1_2_REG        0x0000
-#define EEPROM_IA_3_4_REG        0x0001
-#define EEPROM_IA_5_6_REG        0x0002
+#define EEPROM_IA_1_2_REG	0x0000
+#define EEPROM_IA_3_4_REG	0x0001
+#define EEPROM_IA_5_6_REG	0x0002
 #define EEPROM_COMPATIBILITY_REG 0x0003
-#define EEPROM_PBA_1_2_REG       0x0008
-#define EEPROM_PBA_3_4_REG       0x0009
+#define EEPROM_PBA_1_2_REG	0x0008
+#define EEPROM_PBA_3_4_REG	0x0009
 #define EEPROM_INIT_CONTROL1_REG 0x000A
-#define EEPROM_SUBSYS_ID_REG     0x000B
-#define EEPROM_SUBVEND_ID_REG    0x000C
-#define EEPROM_DEVICE_ID_REG     0x000D
-#define EEPROM_VENDOR_ID_REG     0x000E
+#define EEPROM_SUBSYS_ID_REG	0x000B
+#define EEPROM_SUBVEND_ID_REG	0x000C
+#define EEPROM_DEVICE_ID_REG	0x000D
+#define EEPROM_VENDOR_ID_REG	0x000E
 #define EEPROM_INIT_CONTROL2_REG 0x000F
-#define EEPROM_SWDPINS_REG       0x0020
+#define EEPROM_SWDPINS_REG	0x0020
 #define EEPROM_CIRCUIT_CTRL_REG  0x0021
 #define EEPROM_D0_D3_POWER_REG   0x0022
-#define EEPROM_FLASH_VERSION     0x0032
-#define EEPROM_CHECKSUM_REG      0x003F
+#define EEPROM_FLASH_VERSION	0x0032
+#define EEPROM_CHECKSUM_REG	0x003F
 
 /* Mask bits for fields in Word 0x0a of the EEPROM */
 
@@ -73,26 +75,26 @@
 /* EEPROM Map defines (WORD OFFSETS)*/
 
 /* EEPROM structure */
-struct ixgb_ee_map_type {
-	uint8_t mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];
-	uint16_t compatibility;
-	uint16_t reserved1[4];
-	uint32_t pba_number;
-	uint16_t init_ctrl_reg_1;
-	uint16_t subsystem_id;
-	uint16_t subvendor_id;
-	uint16_t device_id;
-	uint16_t vendor_id;
-	uint16_t init_ctrl_reg_2;
-	uint16_t oem_reserved[16];
-	uint16_t swdpins_reg;
-	uint16_t circuit_ctrl_reg;
-	uint8_t d3_power;
-	uint8_t d0_power;
-	uint16_t reserved2[28];
-	uint16_t checksum;
-};
 
+struct  ixgb_ee_map_type{
+	uint8_t		mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];
+	uint16_t	compatibility;
+	uint16_t	reserved1[4];		 
+	uint32_t	pba_number;
+	uint16_t	init_ctrl_reg_1;
+	uint16_t	subsystem_id;
+	uint16_t	subvendor_id;
+	uint16_t	device_id;
+	uint16_t	vendor_id;
+	uint16_t	init_ctrl_reg_2;
+	uint16_t	oem_reserved[16];		 
+	uint16_t	swdpins_reg;
+	uint16_t	circuit_ctrl_reg;
+	uint8_t		d3_power;
+	uint8_t		d0_power;
+	uint16_t	reserved2[28];		 
+	uint16_t	checksum;
+};
 /* EEPROM Functions */
 uint16_t ixgb_read_eeprom(struct ixgb_hw *hw, uint16_t reg);
 
@@ -101,5 +75,5 @@ 
 void ixgb_update_eeprom_checksum(struct ixgb_hw *hw);
 
 void ixgb_write_eeprom(struct ixgb_hw *hw, uint16_t reg, uint16_t data);
+#endif /* IXGB_EE_H */
 
-#endif				/* IXGB_EE_H */
diff -up netdev-2.6/drivers/net/ixgb/ixgb_ethtool.c netdev-2.6/drivers/net/ixgb.new/ixgb_ethtool.c
--- netdev-2.6/drivers/net/ixgb/ixgb_ethtool.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_ethtool.c	2004-10-15 13:15:50.000000000 -0700
@@ -51,7 +51,7 @@ struct ixgb_stats {
 };
 
 #define IXGB_STAT(m) sizeof(((struct ixgb_adapter *)0)->m), \
-		      offsetof(struct ixgb_adapter, m)
+			offsetof(struct ixgb_adapter, m)
 static struct ixgb_stats ixgb_gstrings_stats[] = {
 	{"rx_packets", IXGB_STAT(net_stats.rx_packets)},
 	{"tx_packets", IXGB_STAT(net_stats.tx_packets)},
@@ -98,12 +98,13 @@ 
 ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
+
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->port = PORT_FIBRE;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	if (netif_carrier_ok(adapter->netdev)) {
+	if(netif_carrier_ok(adapter->netdev)) {
 		ecmd->speed = SPEED_10000;
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
@@ -119,8 +114,8 @@ ixgb_ethtool_gset(struct net_device *net
 ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
-	if (ecmd->autoneg == AUTONEG_ENABLE ||
-	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
+	if(ecmd->autoneg == AUTONEG_ENABLE ||
+		ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
 	
 	if(netif_running(adapter->netdev)) {
diff -up netdev-2.6/drivers/net/ixgb/ixgb.h netdev-2.6/drivers/net/ixgb.new/ixgb.h
--- netdev-2.6/drivers/net/ixgb/ixgb.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-15 13:15:51.000000000 -0700
@@ -190,4 +190,4 @@ struct ixgb_adapter {
 	struct ixgb_hw_stats stats;
 	uint32_t pci_state[16];
 };
-#endif				/* _IXGB_H_ */
+#endif /* _IXGB_H_ */
diff -up netdev-2.6/drivers/net/ixgb/ixgb_hw.c netdev-2.6/drivers/net/ixgb.new/ixgb_hw.c
--- netdev-2.6/drivers/net/ixgb/ixgb_hw.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_hw.c	2004-10-15 13:15:52.000000000 -0700
@@ -53,9 +53,14 @@ static void ixgb_optics_reset(struct ixg
 {
 	uint32_t ctrl_reg;
 
-	ctrl_reg = IXGB_CTRL0_RST | IXGB_CTRL0_SDP3_DIR |	/* All pins are Output=1 */
-	    IXGB_CTRL0_SDP2_DIR | IXGB_CTRL0_SDP1_DIR | IXGB_CTRL0_SDP0_DIR | IXGB_CTRL0_SDP3 |	/* Initial value 1101   */
-	    IXGB_CTRL0_SDP2 | IXGB_CTRL0_SDP0;
+	ctrl_reg =  IXGB_CTRL0_RST |
+			IXGB_CTRL0_SDP3_DIR |   /* All pins are Output=1 */
+			IXGB_CTRL0_SDP2_DIR |
+			IXGB_CTRL0_SDP1_DIR |
+			IXGB_CTRL0_SDP0_DIR |
+			IXGB_CTRL0_SDP3	 |   /* Initial value 1101   */
+			IXGB_CTRL0_SDP2	 |
+			IXGB_CTRL0_SDP0;
 
 #ifdef HP_ZX1
 	/* Workaround for 82597EX reset errata */
@@ -84,7 +82,8 @@ uint32_t ixgb_mac_reset(struct ixgb_hw *
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-boolean_t ixgb_adapter_stop(struct ixgb_hw * hw)
+boolean_t
+ixgb_adapter_stop(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
 	uint32_t icr_reg;
@@ -94,7 +94,7 @@ boolean_t ixgb_adapter_stop(struct ixgb_
 	/* If we are stopped or resetting exit gracefully and wait to be
 	 * started again before accessing the hardware.
 	 */
-	if (hw->adapter_stopped) {
+	if(hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is already stopped!!!\n");
 		return FALSE;
 	}
@@ -144,7 +149,8 @@ boolean_t ixgb_adapter_stop(struct ixgb_
  *
  * Returns: the vendor of the XPAK optics module.
  *****************************************************************************/
-static ixgb_xpak_vendor ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
+static ixgb_xpak_vendor
+ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 {
 	uint32_t i;
 	uint16_t vendor_name[5];
@@ -156,17 +161,18 @@ static ixgb_xpak_vendor ixgb_identify_xp
 	 * registers.  These are standard XENPAK/XPAK registers, so all XPAK
 	 * devices should implement them. */
 	for (i = 0; i < 5; i++) {
-		vendor_name[i] = ixgb_read_phy_reg(hw,
-						   MDIO_PMA_PMD_XPAK_VENDOR_NAME
-						   + i, IXGB_PHY_ADDRESS,
-						   MDIO_PMA_PMD_DID);
+		vendor_name[i] = ixgb_read_phy_reg(hw,
+						MDIO_PMA_PMD_XPAK_VENDOR_NAME + i,
+						IXGB_PHY_ADDRESS,
+						MDIO_PMA_PMD_DID);
 	}
 
 	/* Determine the actual vendor */
 	if (vendor_name[0] == 'I' &&
-	    vendor_name[1] == 'N' &&
-	    vendor_name[2] == 'T' &&
-	    vendor_name[3] == 'E' && vendor_name[4] == 'L') {
+		vendor_name[1] == 'N' &&
+		vendor_name[2] == 'T' &&
+		vendor_name[3] == 'E' &&
+		vendor_name[4] == 'L') {
 		xpak_vendor = ixgb_xpak_vendor_intel;
 	} else {
 		xpak_vendor = ixgb_xpak_vendor_infineon;
@@ -183,7 +161,8 @@ 
  *
  * Returns: the phy type of the adapter.
  *****************************************************************************/
-static ixgb_phy_type ixgb_identify_phy(struct ixgb_hw *hw)
+static ixgb_phy_type
+ixgb_identify_phy(struct ixgb_hw *hw)
 {
 	ixgb_phy_type phy_type;
 	ixgb_xpak_vendor xpak_vendor;
@@ -237,7 +243,8 @@ static ixgb_phy_type ixgb_identify_phy(s
  *      TRUE if successful,
  *      FALSE if unrecoverable problems were encountered.
  *****************************************************************************/
-boolean_t ixgb_init_hw(struct ixgb_hw * hw)
+boolean_t
+ixgb_init_hw(struct ixgb_hw *hw)
 {
 	uint32_t i;
 	uint32_t ctrl_reg;
@@ -266,7 +275,7 @@ boolean_t ixgb_init_hw(struct ixgb_hw * 
 	msec_delay(IXGB_DELAY_AFTER_EE_RESET);
 
 	if (ixgb_get_eeprom_data(hw) == FALSE) {
-		return (FALSE);
+		return(FALSE);
 	}
 
 	/* Use the device id to determine the type of phy/transceiver. */
@@ -295,7 +305,7 @@ boolean_t ixgb_init_hw(struct ixgb_hw * 
 
 	/* Zero out the Multicast HASH table */
 	DEBUGOUT("Zeroing the MTA\n");
-	for (i = 0; i < IXGB_MC_TBL_SIZE; i++)
+	for(i = 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
 
 	/* Zero out the VLAN Filter Table Array */
@@ -322,7 +332,8 @@ boolean_t ixgb_init_hw(struct ixgb_hw * 
  * of the receive addresss registers. Clears the multicast table. Assumes
  * the receiver is in reset when the routine is called.
  *****************************************************************************/
-void ixgb_init_rx_addrs(struct ixgb_hw *hw)
+void
+ixgb_init_rx_addrs(struct ixgb_hw *hw)
 {
 	uint32_t i;
 
@@ -338,22 +344,27 @@ void ixgb_init_rx_addrs(struct ixgb_hw *
 		/* Get the MAC address from the eeprom for later reference */
 		ixgb_get_ee_mac_addr(hw, hw->curr_mac_addr);
 
-		DEBUGOUT3(" Keeping Permanent MAC Addr =%.2X %.2X %.2X ",
-			  hw->curr_mac_addr[0],
-			  hw->curr_mac_addr[1], hw->curr_mac_addr[2]);
-		DEBUGOUT3("%.2X %.2X %.2X\n",
-			  hw->curr_mac_addr[3],
-			  hw->curr_mac_addr[4], hw->curr_mac_addr[5]);
+		DEBUGOUT3(" Keeping Permanent MAC Addr =%.2X %.2X %.2X ",
+			hw->curr_mac_addr[0],
+			hw->curr_mac_addr[1],
+			hw->curr_mac_addr[2]);
+	 	DEBUGOUT3("%.2X %.2X %.2X\n",
+			hw->curr_mac_addr[3],
+			hw->curr_mac_addr[4],
+			hw->curr_mac_addr[5]);
 	} else {
 
-		/* Setup the receive address. */
-		DEBUGOUT("Overriding MAC Address in RAR[0]\n");
-		DEBUGOUT3(" New MAC Addr =%.2X %.2X %.2X ",
-			  hw->curr_mac_addr[0],
-			  hw->curr_mac_addr[1], hw->curr_mac_addr[2]);
-		DEBUGOUT3("%.2X %.2X %.2X\n",
-			  hw->curr_mac_addr[3],
-			  hw->curr_mac_addr[4], hw->curr_mac_addr[5]);
+			/* Setup the receive address. */
+		DEBUGOUT("Overriding MAC Address in RAR[0]\n");
+		DEBUGOUT3(" New MAC Addr =%.2X %.2X %.2X ",
+			hw->curr_mac_addr[0],
+			hw->curr_mac_addr[1],
+			hw->curr_mac_addr[2]);
+		DEBUGOUT3("%.2X %.2X %.2X\n",
+			hw->curr_mac_addr[3],
+			hw->curr_mac_addr[4],
+			hw->curr_mac_addr[5]);
+
 
 		ixgb_rar_set(hw, hw->curr_mac_addr, 0);
 	}
@@ -360,7 +344,7 @@ 
 
 	/* Zero out the other 15 receive addresses. */
 	DEBUGOUT("Clearing RAR[1-15]\n");
-	for (i = 1; i < IXGB_RAR_ENTRIES; i++) {
+	for(i = 1; i < IXGB_RAR_ENTRIES; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 	}
@@ -383,8 +392,9 @@ void ixgb_init_rx_addrs(struct ixgb_hw *
  *****************************************************************************/
 void
 ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-			 uint8_t * mc_addr_list,
-			 uint32_t mc_addr_count, uint32_t pad)
+			  uint8_t *mc_addr_list,
+			  uint32_t mc_addr_count,
+			  uint32_t pad)
 {
 	uint32_t hash_value;
 	uint32_t i;
@@ -397,7 +406,7 @@ ixgb_mc_addr_list_update(struct ixgb_hw 
 
 	/* Clear RAR[1-15] */
 	DEBUGOUT(" Clearing RAR[1-15]\n");
-	for (i = rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
+	for(i = rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 	}
@@ -404,30 +406,25 @@ 
 
 	/* Clear the MTA */
 	DEBUGOUT(" Clearing MTA\n");
-	for (i = 0; i < IXGB_MC_TBL_SIZE; i++) {
+	for(i = 0; i < IXGB_MC_TBL_SIZE; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
 	}
 
 	/* Add the new addresses */
-	for (i = 0; i < mc_addr_count; i++) {
+	for(i = 0; i < mc_addr_count; i++) {
 		DEBUGOUT(" Adding the multicast addresses:\n");
 		DEBUGOUT7(" MC Addr #%d =%.2X %.2X %.2X %.2X %.2X %.2X\n", i,
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       1],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       2],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       3],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       4],
-			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) +
-				       5]);
+			mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)],
+			mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) + 1],
+			mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) + 2],
+			mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) + 3],
+			mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) + 4],
+			mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad) + 5]);
 
 		/* Place this multicast address in the RAR if there is room, *
 		 * else put it in the MTA
 		 */
-		if (rar_used_count < IXGB_RAR_ENTRIES) {
+		if(rar_used_count < IXGB_RAR_ENTRIES) {
 			ixgb_rar_set(hw,
 				     mc_addr_list +
 				     (i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)),
@@ -435,11 +406,9 @@ 
 			DEBUGOUT1("Added a multicast address to RAR[%d]\n", i);
 			rar_used_count++;
 		} else {
-			hash_value = ixgb_hash_mc_addr(hw,
-						       mc_addr_list +
-						       (i *
-							(IXGB_ETH_LENGTH_OF_ADDRESS
-							 + pad)));
+			 hash_value = ixgb_hash_mc_addr(hw,
+					mc_addr_list +
+					(i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)));
 
 			DEBUGOUT1(" Hash value = 0x%03X\n", hash_value);
 
@@ -460,7 +466,9 @@ ixgb_mc_addr_list_update(struct ixgb_hw 
  * Returns:
  *      The hash value
  *****************************************************************************/
-static uint32_t ixgb_hash_mc_addr(struct ixgb_hw *hw, uint8_t * mc_addr)
+static uint32_t
+ixgb_hash_mc_addr(struct ixgb_hw *hw,
+		   uint8_t *mc_addr)
 {
 	uint32_t hash_value = 0;
 
@@ -472,28 +484,25 @@ static uint32_t ixgb_hash_mc_addr(struct
 	switch (hw->mc_filter_type) {
 		/* [0] [1] [2] [3] [4] [5]
 		 * 01  AA  00  12  34  56
-		 * LSB                 MSB - According to H/W docs */
-	case 0:
-		/* [47:36] i.e. 0x563 for above example address */
-		hash_value =
-		    ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
-		break;
-	case 1:		/* [46:35] i.e. 0xAC6 for above example address */
-		hash_value =
-		    ((mc_addr[4] >> 3) | (((uint16_t) mc_addr[5]) << 5));
-		break;
-	case 2:		/* [45:34] i.e. 0x5D8 for above example address */
-		hash_value =
-		    ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
-		break;
-	case 3:		/* [43:32] i.e. 0x634 for above example address */
-		hash_value = ((mc_addr[4]) | (((uint16_t) mc_addr[5]) << 8));
-		break;
-	default:
-		/* Invalid mc_filter_type, what should we do? */
-		DEBUGOUT("MC filter type param set incorrectly\n");
-		ASSERT(0);
-		break;
+	 * LSB MSB - According to H/W docs */
+	case 0:
+		/* [47:36] i.e. 0x563 for above example address */
+		hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+		break;
+	case 1: /* [46:35] i.e. 0xAC6 for above example address */
+		hash_value = ((mc_addr[4] >> 3) | (((uint16_t) mc_addr[5]) << 5));
+		break;
+	case 2: /* [45:34] i.e. 0x5D8 for above example address */
+		hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+		break;
+	case 3: /* [43:32] i.e. 0x634 for above example address */
+		hash_value = ((mc_addr[4]) | (((uint16_t) mc_addr[5]) << 8));
+		break;
+	default:
+		/* Invalid mc_filter_type, what should we do? */
+		DEBUGOUT("MC filter type param set incorrectly\n");
+		ASSERT(0);
+		break;
 	}
 
 	hash_value &= 0xFFF;
@@ -506,7 +515,9 @@ static uint32_t ixgb_hash_mc_addr(struct
  * hw - Struct containing variables accessed by shared code
  * hash_value - Multicast address hash value
  *****************************************************************************/
-static void ixgb_mta_set(struct ixgb_hw *hw, uint32_t hash_value)
+static void
+ixgb_mta_set(struct ixgb_hw *hw,
+	  uint32_t hash_value)
 {
 	uint32_t hash_bit, hash_reg;
 	uint32_t mta_reg;
@@ -538,7 +549,10 @@ static void ixgb_mta_set(struct ixgb_hw 
  * addr - Address to put into receive address register
  * index - Receive address register to write
  *****************************************************************************/
-void ixgb_rar_set(struct ixgb_hw *hw, uint8_t * addr, uint32_t index)
+void
+ixgb_rar_set(struct ixgb_hw *hw,
+	  uint8_t *addr,
+	  uint32_t index)
 {
 	uint32_t rar_low, rar_high;
 
@@ -548,11 +562,13 @@ void ixgb_rar_set(struct ixgb_hw *hw, ui
 	 * from network order (big endian) to little endian
 	 */
 	rar_low = ((uint32_t) addr[0] |
-		   ((uint32_t) addr[1] << 8) |
-		   ((uint32_t) addr[2] << 16) | ((uint32_t) addr[3] << 24));
+		   ((uint32_t) addr[1] << 8) |
+		   ((uint32_t) addr[2] << 16) |
+		   ((uint32_t) addr[3] << 24));
 
 	rar_high = ((uint32_t) addr[4] |
-		    ((uint32_t) addr[5] << 8) | IXGB_RAH_AV);
+			((uint32_t) addr[5] << 8) |
+			IXGB_RAH_AV);
 
 	IXGB_WRITE_REG_ARRAY(hw, RA, (index << 1), rar_low);
 	IXGB_WRITE_REG_ARRAY(hw, RA, ((index << 1) + 1), rar_high);
@@ -566,7 +582,10 @@ void ixgb_rar_set(struct ixgb_hw *hw, ui
  * offset - Offset in VLAN filer table to write
  * value - Value to write into VLAN filter table
  *****************************************************************************/
-void ixgb_write_vfta(struct ixgb_hw *hw, uint32_t offset, uint32_t value)
+void
+ixgb_write_vfta(struct ixgb_hw *hw,
+		 uint32_t offset,
+		 uint32_t value)
 {
 	IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, value);
 	return;
@@ -577,11 +596,12 @@ void ixgb_write_vfta(struct ixgb_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_clear_vfta(struct ixgb_hw *hw)
+void
+ixgb_clear_vfta(struct ixgb_hw *hw)
 {
 	uint32_t offset;
 
-	for (offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
+	for(offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
 		IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, 0);
 	return;
 }
@@ -592,7 +600,8 @@ void ixgb_clear_vfta(struct ixgb_hw *hw)
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
 
-boolean_t ixgb_setup_fc(struct ixgb_hw * hw)
+boolean_t
+ixgb_setup_fc(struct ixgb_hw *hw)
 {
 	uint32_t ctrl_reg;
 	uint32_t pap_reg = 0;	/* by default, assume no pause time */
@@ -660,16 +668,16 @@ boolean_t ixgb_setup_fc(struct ixgb_hw *
 	 * ability to transmit pause frames in not enabled, then these
 	 * registers will be set to 0.
 	 */
-	if (!(hw->fc.type & ixgb_fc_tx_pause)) {
+	if(!(hw->fc.type & ixgb_fc_tx_pause)) {
 		IXGB_WRITE_REG(hw, FCRTL, 0);
 		IXGB_WRITE_REG(hw, FCRTH, 0);
 	} else {
-		/* We need to set up the Receive Threshold high and low water
-		 * marks as well as (optionally) enabling the transmission of XON frames.
-		 */
-		if (hw->fc.send_xon) {
+		/* We need to set up the Receive Threshold high and low water
+		 * marks as well as (optionally) enabling the transmission of XON frames.
+		 */
+		if(hw->fc.send_xon) {
 			IXGB_WRITE_REG(hw, FCRTL,
-				       (hw->fc.low_water | IXGB_FCRTL_XONE));
+					(hw->fc.low_water | IXGB_FCRTL_XONE));
 		} else {
 			IXGB_WRITE_REG(hw, FCRTL, hw->fc.low_water);
 		}
@@ -694,9 +702,10 @@ boolean_t ixgb_setup_fc(struct ixgb_hw *
  * read command.
  *****************************************************************************/
 uint16_t
-ixgb_read_phy_reg(struct ixgb_hw * hw,
-		  uint32_t reg_address,
-		  uint32_t phy_address, uint32_t device_type)
+ixgb_read_phy_reg(struct ixgb_hw *hw,
+			uint32_t reg_address,
+			uint32_t phy_address,
+			uint32_t device_type)
 {
 	uint32_t i;
 	uint32_t data;
@@ -714,14 +715,14 @@ ixgb_read_phy_reg(struct ixgb_hw * hw,
 
 	IXGB_WRITE_REG(hw, MSCA, command);
 
-    /**************************************************************
-    ** Check every 10 usec to see if the address cycle completed
-    ** The COMMAND bit will clear when the operation is complete.
-    ** This may take as long as 64 usecs (we'll wait 100 usecs max)
-    ** from the CPU Write to the Ready bit assertion.
-    **************************************************************/
+	/**************************************************************
+	** Check every 10 usec to see if the address cycle completed
+	** The COMMAND bit will clear when the operation is complete.
+	** This may take as long as 64 usecs (we'll wait 100 usecs max)
+	** from the CPU Write to the Ready bit assertion.
+	**************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++) {
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -740,14 +742,14 @@ ixgb_read_phy_reg(struct ixgb_hw * hw,
 
 	IXGB_WRITE_REG(hw, MSCA, command);
 
-    /**************************************************************
-    ** Check every 10 usec to see if the read command completed
-    ** The COMMAND bit will clear when the operation is complete.
-    ** The read may take as long as 64 usecs (we'll wait 100 usecs max)
-    ** from the CPU Write to the Ready bit assertion.
-    **************************************************************/
+	/**************************************************************
+	** Check every 10 usec to see if the read command completed
+	** The COMMAND bit will clear when the operation is complete.
+	** The read may take as long as 64 usecs (we'll wait 100 usecs max)
+	** from the CPU Write to the Ready bit assertion.
+	**************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++) {
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -763,7 +773,7 @@ ixgb_read_phy_reg(struct ixgb_hw * hw,
 	 */
 	data = IXGB_READ_REG(hw, MSRWD);
 	data >>= IXGB_MSRWD_READ_DATA_SHIFT;
-	return ((uint16_t) data);
+	return((uint16_t)data);
 }
 
 /******************************************************************************
@@ -785,8 +795,10 @@ ixgb_read_phy_reg(struct ixgb_hw * hw,
  *****************************************************************************/
 void
 ixgb_write_phy_reg(struct ixgb_hw *hw,
-		   uint32_t reg_address,
-		   uint32_t phy_address, uint32_t device_type, uint16_t data)
+		uint32_t reg_address,
+		uint32_t phy_address,
+		uint32_t device_type,
+		uint16_t data)
 {
 	uint32_t i;
 	uint32_t command = 0;
@@ -796,7 +806,7 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 	ASSERT(device_type <= IXGB_MAX_PHY_DEV_TYPE);
 
 	/* Put the data in the MDIO Read/Write Data register */
-	IXGB_WRITE_REG(hw, MSRWD, (uint32_t) data);
+	IXGB_WRITE_REG(hw, MSRWD, (uint32_t)data);
 
 	/* Setup and write the address cycle command */
 	command = ((reg_address << IXGB_MSCA_NP_ADDR_SHIFT) |
@@ -806,14 +806,14 @@ 
 
 	IXGB_WRITE_REG(hw, MSCA, command);
 
-    /**************************************************************
-    ** Check every 10 usec to see if the address cycle completed
-    ** The COMMAND bit will clear when the operation is complete.
-    ** This may take as long as 64 usecs (we'll wait 100 usecs max)
-    ** from the CPU Write to the Ready bit assertion.
-    **************************************************************/
+	/**************************************************************
+	** Check every 10 usec to see if the address cycle completed
+	** The COMMAND bit will clear when the operation is complete.
+	** This may take as long as 64 usecs (we'll wait 100 usecs max)
+	** from the CPU Write to the Ready bit assertion.
+	**************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++) {
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -832,14 +836,14 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 
 	IXGB_WRITE_REG(hw, MSCA, command);
 
-    /**************************************************************
-    ** Check every 10 usec to see if the read command completed
-    ** The COMMAND bit will clear when the operation is complete.
-    ** The write may take as long as 64 usecs (we'll wait 100 usecs max)
-    ** from the CPU Write to the Ready bit assertion.
-    **************************************************************/
+	/**************************************************************
+	** Check every 10 usec to see if the read command completed
+	** The COMMAND bit will clear when the operation is complete.
+	** The write may take as long as 64 usecs (we'll wait 100 usecs max)
+	** from the CPU Write to the Ready bit assertion.
+	**************************************************************/
 
-	for (i = 0; i < 10; i++) {
+	for(i = 0; i < 10; i++) {
 		udelay(10);
 
 		command = IXGB_READ_REG(hw, MSCA);
@@ -860,7 +884,8 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
  *
  * Called by any function that needs to check the link status of the adapter.
  *****************************************************************************/
-void ixgb_check_for_link(struct ixgb_hw *hw)
+void
+ixgb_check_for_link(struct ixgb_hw *hw)
 {
 	uint32_t status_reg;
 	uint32_t xpcss_reg;
@@ -922,7 +928,8 @@ boolean_t ixgb_check_for_bad_link(struct
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
+void
+ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 {
 	volatile uint32_t temp_reg;
 
@@ -929,7 +928,7 @@ 
 	DEBUGFUNC("ixgb_clear_hw_cntrs");
 
 	/* if we are stopped or resetting exit gracefully */
-	if (hw->adapter_stopped) {
+	if(hw->adapter_stopped) {
 		DEBUGOUT("Exiting because the adapter is stopped!!!\n");
 		return;
 	}
@@ -1002,7 +1009,8 @@ void ixgb_clear_hw_cntrs(struct ixgb_hw 
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_led_on(struct ixgb_hw *hw)
+void
+ixgb_led_on(struct ixgb_hw *hw)
 {
 	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
@@ -1017,7 +1030,8 @@ void ixgb_led_on(struct ixgb_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_led_off(struct ixgb_hw *hw)
+void
+ixgb_led_off(struct ixgb_hw *hw)
 {
 	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
@@ -1032,7 +1040,8 @@ void ixgb_led_off(struct ixgb_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static void ixgb_get_bus_info(struct ixgb_hw *hw)
+static void
+ixgb_get_bus_info(struct ixgb_hw *hw)
 {
 	uint32_t status_reg;
 
@@ -1039,11 +1040,11 @@ 
 	status_reg = IXGB_READ_REG(hw, STATUS);
 
 	hw->bus.type = (status_reg & IXGB_STATUS_PCIX_MODE) ?
-	    ixgb_bus_type_pcix : ixgb_bus_type_pci;
+		ixgb_bus_type_pcix : ixgb_bus_type_pci;
 
 	if (hw->bus.type == ixgb_bus_type_pci) {
 		hw->bus.speed = (status_reg & IXGB_STATUS_PCI_SPD) ?
-		    ixgb_bus_speed_66 : ixgb_bus_speed_33;
+			ixgb_bus_speed_66 : ixgb_bus_speed_33;
 	} else {
 		switch (status_reg & IXGB_STATUS_PCIX_SPD_MASK) {
 		case IXGB_STATUS_PCIX_SPD_66:
@@ -1062,7 +1076,7 @@ static void ixgb_get_bus_info(struct ixg
 	}
 
 	hw->bus.width = (status_reg & IXGB_STATUS_BUS64) ?
-	    ixgb_bus_width_64 : ixgb_bus_width_32;
+		ixgb_bus_width_64 : ixgb_bus_width_32;
 
 	return;
 }
@@ -1073,7 +1076,8 @@ 
  * mac_addr - pointer to MAC address.
  *
  *****************************************************************************/
-boolean_t mac_addr_valid(uint8_t * mac_addr)
+boolean_t
+mac_addr_valid(uint8_t *mac_addr)
 {
 	boolean_t is_valid = TRUE;
 	DEBUGFUNC("mac_addr_valid");
@@ -1090,9 +1120,11 @@ boolean_t mac_addr_valid(uint8_t * mac_a
 	}
 	/* Reject the zero address */
 	else if (mac_addr[0] == 0 &&
-		 mac_addr[1] == 0 &&
-		 mac_addr[2] == 0 &&
-		 mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0) {
+		 mac_addr[1] == 0 &&
+		 mac_addr[2] == 0 &&
+		 mac_addr[3] == 0 &&
+		 mac_addr[4] == 0 &&
+		 mac_addr[5] == 0) {
 		DEBUGOUT("MAC address is all zeros\n");
 		is_valid = FALSE;
 	}
@@ -1105,7 +1122,8 @@ boolean_t mac_addr_valid(uint8_t * mac_a
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-boolean_t ixgb_link_reset(struct ixgb_hw * hw)
+boolean_t
+ixgb_link_reset(struct ixgb_hw *hw)
 {
 	boolean_t link_status = FALSE;
 	uint8_t wait_retries = MAX_RESET_ITERATIONS;
@@ -1135,21 +1122,24 @@ 
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-void ixgb_optics_reset(struct ixgb_hw *hw)
+void
+ixgb_optics_reset(struct ixgb_hw *hw)
 {
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
 		uint16_t mdio_reg;
 
-		ixgb_write_phy_reg(hw,
-				   MDIO_PMA_PMD_CR1,
-				   IXGB_PHY_ADDRESS,
-				   MDIO_PMA_PMD_DID, MDIO_PMA_PMD_CR1_RESET);
-
-		mdio_reg = ixgb_read_phy_reg(hw,
-					     MDIO_PMA_PMD_CR1,
-					     IXGB_PHY_ADDRESS,
-					     MDIO_PMA_PMD_DID);
+		ixgb_write_phy_reg( hw,
+				MDIO_PMA_PMD_CR1,
+				IXGB_PHY_ADDRESS,
+				MDIO_PMA_PMD_DID,
+				MDIO_PMA_PMD_CR1_RESET);
+
+		mdio_reg = ixgb_read_phy_reg( hw,
+				MDIO_PMA_PMD_CR1,
+				IXGB_PHY_ADDRESS,
+				MDIO_PMA_PMD_DID);
 	}
 
 	return;
 }
+
diff -up netdev-2.6/drivers/net/ixgb/ixgb_hw.h netdev-2.6/drivers/net/ixgb.new/ixgb_hw.h
--- netdev-2.6/drivers/net/ixgb/ixgb_hw.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_hw.h	2004-10-15 13:15:53.000000000 -0700
@@ -536,8 +536,8 @@ struct ixgb_rx_desc {
 	uint64_t buff_addr;
 	uint16_t length;
 	uint16_t reserved;
-	uint8_t status;
-	uint8_t errors;
+	uint8_t  status;
+	uint8_t  errors;
 	uint16_t special;
 };
 
@@ -568,8 +570,8 @@ struct ixgb_rx_desc {
 struct ixgb_tx_desc {
 	uint64_t buff_addr;
 	uint32_t cmd_type_len;
-	uint8_t status;
-	uint8_t popts;
+	uint8_t  status;
+	uint8_t  popts;
 	uint16_t vlan;
 };
 
@@ -593,15 +570,15 @@ 
 #define IXGB_TX_DESC_SPECIAL_PRI_SHIFT  IXGB_RX_DESC_SPECIAL_PRI_SHIFT	/* Priority is in upper 3 of 16 */
 
 struct ixgb_context_desc {
-	uint8_t ipcss;
-	uint8_t ipcso;
+	uint8_t  ipcss;
+	uint8_t  ipcso;
 	uint16_t ipcse;
-	uint8_t tucss;
-	uint8_t tucso;
+	uint8_t  tucss;
+	uint8_t  tucso;
 	uint16_t tucse;
 	uint32_t cmd_type_len;
-	uint8_t status;
-	uint8_t hdr_len;
+	uint8_t  status;
+	uint8_t  hdr_len;
 	uint16_t mss;
 };
 
@@ -648,7 +650,7 @@ struct ixgb_flash_buffer {
  * This is a little-endian specific check.
  */
 #define IS_MULTICAST(Address) \
-    (boolean_t)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
+	(boolean_t)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
 
 /*
  * Check whether an address is broadcast.
@@ -789,32 +792,39 @@ extern void ixgb_check_for_link(struct i
 extern boolean_t ixgb_check_for_bad_link(struct ixgb_hw *hw);
 extern boolean_t ixgb_setup_fc(struct ixgb_hw *hw);
 extern void ixgb_clear_hw_cntrs(struct ixgb_hw *hw);
-extern boolean_t mac_addr_valid(uint8_t * mac_addr);
+extern boolean_t mac_addr_valid(uint8_t *mac_addr);
 
 extern uint16_t ixgb_read_phy_reg(struct ixgb_hw *hw,
-				  uint32_t reg_addr,
-				  uint32_t phy_addr, uint32_t device_type);
+				uint32_t reg_addr,
+				uint32_t phy_addr,
+				uint32_t device_type);
 
 extern void ixgb_write_phy_reg(struct ixgb_hw *hw,
-			       uint32_t reg_addr,
-			       uint32_t phy_addr,
-			       uint32_t device_type, uint16_t data);
+				uint32_t reg_addr,
+				uint32_t phy_addr,
+				uint32_t device_type,
+				uint16_t data);
+
+extern void ixgb_rar_set(struct ixgb_hw *hw,
+				uint8_t *addr,
+				uint32_t index);
 
-extern void ixgb_rar_set(struct ixgb_hw *hw, uint8_t * addr, uint32_t index);
 
 /* Filters (multicast, vlan, receive) */
 extern void ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-				     uint8_t * mc_addr_list,
-				     uint32_t mc_addr_count, uint32_t pad);
+				   uint8_t * mc_addr_list,
+				   uint32_t mc_addr_count,
+				   uint32_t pad);
 
 /* Vfta functions */
 extern void ixgb_write_vfta(struct ixgb_hw *hw,
-			    uint32_t offset, uint32_t value);
+				 uint32_t offset,
+				 uint32_t value);
 
 extern void ixgb_clear_vfta(struct ixgb_hw *hw);
 
 /* Access functions to eeprom data */
-void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t * mac_addr);
+void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t *mac_addr);
 uint16_t ixgb_get_ee_compatibility(struct ixgb_hw *hw);
 uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
 uint16_t ixgb_get_ee_init_ctrl_reg_1(struct ixgb_hw *hw);
@@ -832,6 +828,9 @@ uint16_t ixgb_get_ee_subvendor_id(struct
 /* Everything else */
 void ixgb_led_on(struct ixgb_hw *hw);
 void ixgb_led_off(struct ixgb_hw *hw);
-void ixgb_write_pci_cfg(struct ixgb_hw *hw, uint32_t reg, uint16_t * value);
+void ixgb_write_pci_cfg(struct ixgb_hw *hw,
+			 uint32_t reg,
+			 uint16_t * value);
+
 
-#endif				/* _IXGB_HW_H_ */
+#endif /* _IXGB_HW_H_ */
diff -up netdev-2.6/drivers/net/ixgb/ixgb_ids.h netdev-2.6/drivers/net/ixgb.new/ixgb_ids.h
--- netdev-2.6/drivers/net/ixgb/ixgb_ids.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_ids.h	2004-10-15 13:15:54.000000000 -0700
@@ -33,17 +33,17 @@
 ** The Device and Vendor IDs for 10 Gigabit MACs
 **********************************************************************/
 
-#define INTEL_VENDOR_ID         0x8086
-#define INTEL_SUBVENDOR_ID      0x8086
 
-#define IXGB_DEVICE_ID_82597EX      0x1048
-#define IXGB_DEVICE_ID_82597EX_SR   0x1A48
 
-#define IXGB_SUBDEVICE_ID_A11F  0xA11F
-#define IXGB_SUBDEVICE_ID_A01F  0xA01F
+#define INTEL_VENDOR_ID		0x8086
+#define INTEL_SUBVENDOR_ID		0x8086
 
 
+#define IXGB_DEVICE_ID_82597EX		0x1048   
+#define IXGB_DEVICE_ID_82597EX_SR	0x1A48   
+#define IXGB_SUBDEVICE_ID_A11F  	0xA11F   
+#define IXGB_SUBDEVICE_ID_A01F		0xA01F   
 
-#endif				/* #ifndef _IXGB_IDS_H_ */
+#endif /* #ifndef _IXGB_IDS_H_ */
 
 /* End of File */
diff -up netdev-2.6/drivers/net/ixgb/ixgb_main.c netdev-2.6/drivers/net/ixgb.new/ixgb_main.c
--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-15 13:15:55.000000000 -0700
@@ -97,7 +97,7 @@ static void __devexit ixgb_remove(struct
 #ifdef CONFIG_IXGB_NAPI
 static int ixgb_clean(struct net_device *netdev, int *budget);
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
-				   int *work_done, int work_to_do);
+				int *work_done, int work_to_do);
 #else
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
 #endif
@@ -121,9 +121,9 @@ 
 #endif
 
 struct notifier_block ixgb_notifier_reboot = {
-	.notifier_call = ixgb_notify_reboot,
-	.next = NULL,
-	.priority = 0
+	.notifier_call	= ixgb_notify_reboot,
+	.next		= NULL,
+	.priority	= 0
 };
 
 /* Exported from other modules */
@@ -131,13 +131,13 @@ 
 extern void ixgb_check_options(struct ixgb_adapter *adapter);
 
 static struct pci_driver ixgb_driver = {
-	.name = ixgb_driver_name,
+	.name	  = ixgb_driver_name,
 	.id_table = ixgb_pci_tbl,
-	.probe = ixgb_probe,
-	.remove = __devexit_p(ixgb_remove),
+	.probe	  = ixgb_probe,
+	.remove   = __devexit_p(ixgb_remove),
 	/* Power Managment Hooks */
-	.suspend = NULL,
-	.resume = NULL
+	.suspend  = NULL,
+	.resume	  = NULL
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -145,10 +142,10 @@ MODULE_DESCRIPTION("Intel(R) PRO/10GbE N
 MODULE_LICENSE("GPL");
 
 /* some defines for controlling descriptor fetches in h/w */
-#define RXDCTL_PTHRESH_DEFAULT 128	/* chip considers prefech below this */
-#define RXDCTL_HTHRESH_DEFAULT 16	/* chip will only prefetch if tail is 
-					   pushed this many descriptors from head */
-#define RXDCTL_WTHRESH_DEFAULT 16	/* chip writes back at this many or RXT0 */
+#define RXDCTL_PTHRESH_DEFAULT 128 /* chip considers prefech below this */
+#define RXDCTL_HTHRESH_DEFAULT 16  /* chip will only prefetch if tail is 
+					pushed this many descriptors from head */
+#define RXDCTL_WTHRESH_DEFAULT 16  /* chip writes back at this many or RXT0 */
 
 /**
  * ixgb_init_module - Driver Registration Routine
@@ -157,16 +154,17 @@ MODULE_LICENSE("GPL");
  * loaded. All it does is register with the PCI subsystem.
  **/
 
-static int __init ixgb_init_module(void)
+static int __init
+ixgb_init_module(void)
 {
 	int ret;
 	printk(KERN_INFO "%s - version %s\n",
-	       ixgb_driver_string, ixgb_driver_version);
+		   ixgb_driver_string, ixgb_driver_version);
 
 	printk(KERN_INFO "%s\n", ixgb_copyright);
 
 	ret = pci_module_init(&ixgb_driver);
-	if (ret >= 0) {
+	if(ret >= 0) {
 		register_reboot_notifier(&ixgb_notifier_reboot);
 	}
 	return ret;
@@ -181,7 +178,8 @@ module_init(ixgb_init_module);
  * from memory.
  **/
 
-static void __exit ixgb_exit_module(void)
+static void __exit
+ixgb_exit_module(void)
 {
 	unregister_reboot_notifier(&ixgb_notifier_reboot);
 	pci_unregister_driver(&ixgb_driver);
@@ -217,7 +186,8 @@ static void __exit ixgb_exit_module(void
 	}
 }
 
-int ixgb_up(struct ixgb_adapter *adapter)
+int
+ixgb_up(struct ixgb_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
@@ -235,27 +205,27 @@ int ixgb_up(struct ixgb_adapter *adapter
 	ixgb_configure_rx(adapter);
 	ixgb_alloc_rx_buffers(adapter);
 
-	if ((err = request_irq(adapter->pdev->irq, &ixgb_intr,
-			       SA_SHIRQ | SA_SAMPLE_RANDOM,
-			       netdev->name, netdev)))
+	if((err = request_irq(adapter->pdev->irq, &ixgb_intr,
+				  SA_SHIRQ | SA_SAMPLE_RANDOM,
+				  netdev->name, netdev)))
 		return err;
 
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
 
-	if ((hw->max_frame_size != max_frame) ||
-	    (hw->max_frame_size !=
-	     (IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
+	if((hw->max_frame_size != max_frame) ||
+		(hw->max_frame_size !=
+		(IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
 
 		hw->max_frame_size = max_frame;
 
 		IXGB_WRITE_REG(hw, MFS, hw->max_frame_size << IXGB_MFS_SHIFT);
 
-		if (hw->max_frame_size >
-		    IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
+		if(hw->max_frame_size >
+		   IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
 			uint32_t ctrl0 = IXGB_READ_REG(hw, CTRL0);
 
-			if (!(ctrl0 & IXGB_CTRL0_JFE)) {
+			if(!(ctrl0 & IXGB_CTRL0_JFE)) {
 				ctrl0 |= IXGB_CTRL0_JFE;
 				IXGB_WRITE_REG(hw, CTRL0, ctrl0);
 			}
@@ -268,13 +238,14 @@ int ixgb_up(struct ixgb_adapter *adapter
 	return 0;
 }
 
-void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
+void
+ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 {
 	struct net_device *netdev = adapter->netdev;
 
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
-	if (kill_watchdog)
+	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -286,11 +256,12 @@ void ixgb_down(struct ixgb_adapter *adap
 	ixgb_clean_rx_ring(adapter);
 }
 
-void ixgb_reset(struct ixgb_adapter *adapter)
+void
+ixgb_reset(struct ixgb_adapter *adapter)
 {
 
 	ixgb_adapter_stop(&adapter->hw);
-	if (!ixgb_init_hw(&adapter->hw))
+	if(!ixgb_init_hw(&adapter->hw))
 		IXGB_DBG("ixgb_init_hw failed.\n");
 }
 
@@ -307,7 +277,8 @@ void ixgb_reset(struct ixgb_adapter *ada
  **/
 
 static int __devinit
-ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+ixgb_probe(struct pci_dev *pdev,
+		const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct ixgb_adapter *adapter;
@@ -318,13 +288,13 @@ ixgb_probe(struct pci_dev *pdev, const s
 	int i;
 	int err;
 
-	if ((err = pci_enable_device(pdev)))
+	if((err = pci_enable_device(pdev)))
 		return err;
 
-	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if(!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
 		pci_using_dac = 1;
 	} else {
-		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 			IXGB_ERR("No usable DMA configuration, aborting\n");
 			return err;
 		}
@@ -331,13 +288,13 @@ 
 		pci_using_dac = 0;
 	}
 
-	if ((err = pci_request_regions(pdev, ixgb_driver_name)))
+	if((err = pci_request_regions(pdev, ixgb_driver_name)))
 		return err;
 
 	pci_set_master(pdev);
 
 	netdev = alloc_etherdev(sizeof(struct ixgb_adapter));
-	if (!netdev) {
+	if(!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
 	}
@@ -355,15 +325,15 @@ ixgb_probe(struct pci_dev *pdev, const s
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
 	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
-	if (!adapter->hw.hw_addr) {
+	if(!adapter->hw.hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
 	}
 
-	for (i = BAR_1; i <= BAR_5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
+	for(i = BAR_1; i <= BAR_5; i++) {
+		if(pci_resource_len(pdev, i) == 0)
 			continue;
-		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+		if(pci_resource_flags(pdev, i) & IORESOURCE_IO) {
 			adapter->hw.io_base = pci_resource_start(pdev, i);
 			break;
 		}
@@ -400,22 +371,24 @@ ixgb_probe(struct pci_dev *pdev, const s
 
 	/* setup the private structure */
 
-	if ((err = ixgb_sw_init(adapter)))
+	if((err = ixgb_sw_init(adapter)))
 		goto err_sw_init;
 
 	netdev->features = NETIF_F_SG |
-	    NETIF_F_HW_CSUM |
-	    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+			   NETIF_F_HW_CSUM |
+			   NETIF_F_HW_VLAN_TX |
+			   NETIF_F_HW_VLAN_RX |
+			   NETIF_F_HW_VLAN_FILTER;
 #ifdef NETIF_F_TSO
 	netdev->features |= NETIF_F_TSO;
 #endif
 
-	if (pci_using_dac)
+	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	/* make sure the EEPROM is good */
 
-	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
+	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
 		printk(KERN_ERR "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
@@ -423,7 +394,7 @@ ixgb_probe(struct pci_dev *pdev, const s
 
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 
-	if (!is_valid_ether_addr(netdev->dev_addr)) {
+	if(!is_valid_ether_addr(netdev->dev_addr)) {
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -435,9 +394,9 @@ 
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->tx_timeout_task,
-		  (void (*)(void *))ixgb_tx_timeout_task, netdev);
+		(void (*)(void *))ixgb_tx_timeout_task, netdev);
 
-	if ((err = register_netdev(netdev)))
+	if((err = register_netdev(netdev)))
 		goto err_register;
 
 	/* we're going to reset, so assume we have no link for now */
@@ -446,7 +419,7 @@ ixgb_probe(struct pci_dev *pdev, const s
 	netif_stop_queue(netdev);
 
 	printk(KERN_INFO "%s: Intel(R) PRO/10GbE Network Connection\n",
-	       netdev->name);
+		   netdev->name);
 	ixgb_check_options(adapter);
 	/* reset the hardware with the new settings */
 
@@ -455,13 +428,13 @@ ixgb_probe(struct pci_dev *pdev, const s
 	cards_found++;
 	return 0;
 
-      err_register:
-      err_sw_init:
-      err_eeprom:
+err_register:
+err_sw_init:
+err_eeprom:
 	iounmap(adapter->hw.hw_addr);
-      err_ioremap:
+err_ioremap:
 	free_netdev(netdev);
-      err_alloc_etherdev:
+err_alloc_etherdev:
 	pci_release_regions(pdev);
 	return err;
 }
@@ -476,7 +449,8 @@ ixgb_probe(struct pci_dev *pdev, const s
  * memory.
  **/
 
-static void __devexit ixgb_remove(struct pci_dev *pdev)
+static void __devexit
+ixgb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev->priv;
@@ -498,7 +473,8 @@ static void __devexit ixgb_remove(struct
  * OS network device settings (MTU size).
  **/
 
-static int __devinit ixgb_sw_init(struct ixgb_adapter *adapter)
+static int __devinit
+ixgb_sw_init(struct ixgb_adapter *adapter)
 {
 	struct ixgb_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
@@ -515,9 +486,9 @@ static int __devinit ixgb_sw_init(struct
 
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
-	if ((hw->device_id == IXGB_DEVICE_ID_82597EX)
-	    || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
-		hw->mac_type = ixgb_82597;
+	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
+	   ||(hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
+			hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
 		printk(KERN_ERR "ixgb: unsupported device id\n");
@@ -545,7 +522,8 @@ static int __devinit ixgb_sw_init(struct
  * and the stack is notified that the interface is ready.
  **/
 
-static int ixgb_open(struct net_device *netdev)
+static int
+ixgb_open(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	int err;
@@ -552,24 +522,24 @@ 
 
 	/* allocate transmit descriptors */
 
-	if ((err = ixgb_setup_tx_resources(adapter)))
+	if((err = ixgb_setup_tx_resources(adapter)))
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
 
-	if ((err = ixgb_setup_rx_resources(adapter)))
+	if((err = ixgb_setup_rx_resources(adapter)))
 		goto err_setup_rx;
 
-	if ((err = ixgb_up(adapter)))
+	if((err = ixgb_up(adapter)))
 		goto err_up;
 
 	return 0;
 
-      err_up:
+err_up:
 	ixgb_free_rx_resources(adapter);
-      err_setup_rx:
+err_setup_rx:
 	ixgb_free_tx_resources(adapter);
-      err_setup_tx:
+err_setup_tx:
 	ixgb_reset(adapter);
 
 	return err;
@@ -587,7 +587,8 @@ static int ixgb_open(struct net_device *
  * hardware, and all transmit and receive resources are freed.
  **/
 
-static int ixgb_close(struct net_device *netdev)
+static int
+ixgb_close(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
@@ -614,8 +583,8 @@ static int ixgb_close(struct net_device 
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * txdr->count;
-	if (!txdr->buffer_info) {
 	txdr->buffer_info = vmalloc(size);
+	if(!txdr->buffer_info) {
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -626,7 +602,7 @@ static int ixgb_setup_tx_resources(struc
 	IXGB_ROUNDUP(txdr->size, 4096);
 
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
-	if (!txdr->desc) {
+	if(!txdr->desc) {
 		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
@@ -645,7 +621,8 @@ static int ixgb_setup_tx_resources(struc
  * Configure the Tx unit of the MAC after a reset.
  **/
 
-static void ixgb_configure_tx(struct ixgb_adapter *adapter)
+static void
+ixgb_configure_tx(struct ixgb_adapter *adapter)
 {
 	uint64_t tdba = adapter->tx_ring.dma;
 	uint32_t tdlen = adapter->tx_ring.count * sizeof(struct ixgb_tx_desc);
@@ -685,8 +698,8 @@ static void ixgb_configure_tx(struct ixg
 
 	/* Setup Transmit Descriptor Settings for this adapter */
 	adapter->tx_cmd_type =
-	    IXGB_TX_DESC_TYPE
-	    | (adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
+		IXGB_TX_DESC_TYPE 
+		| (adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
 }
 
 /**
@@ -704,8 +673,8 @@ static void ixgb_configure_tx(struct ixg
 	int size;
 
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
-	if (!rxdr->buffer_info) {
 	rxdr->buffer_info = vmalloc(size);
+	if(!rxdr->buffer_info) {
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -717,7 +693,7 @@ static int ixgb_setup_rx_resources(struc
 
 	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
 
-	if (!rxdr->desc) {
+	if(!rxdr->desc) {
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
@@ -734,7 +747,8 @@ static int ixgb_setup_rx_resources(struc
  * @adapter: Board private structure
  **/
 
-static void ixgb_setup_rctl(struct ixgb_adapter *adapter)
+static void
+ixgb_setup_rctl(struct ixgb_adapter *adapter)
 {
 	uint32_t rctl;
 
@@ -743,9 +757,9 @@ static void ixgb_setup_rctl(struct ixgb_
 	rctl &= ~(3 << IXGB_RCTL_MO_SHIFT);
 
 	rctl |=
-	    IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 |
-	    IXGB_RCTL_RXEN | IXGB_RCTL_CFF |
-	    (adapter->hw.mc_filter_type << IXGB_RCTL_MO_SHIFT);
+		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 | 
+		IXGB_RCTL_RXEN | IXGB_RCTL_CFF | 
+		(adapter->hw.mc_filter_type << IXGB_RCTL_MO_SHIFT);
 
 	rctl |= IXGB_RCTL_SECRC;
 
@@ -775,7 +789,8 @@ static void ixgb_setup_rctl(struct ixgb_
  * Configure the Rx unit of the MAC after a reset.
  **/
 
-static void ixgb_configure_rx(struct ixgb_adapter *adapter)
+static void
+ixgb_configure_rx(struct ixgb_adapter *adapter)
 {
 	uint64_t rdba = adapter->rx_ring.dma;
 	uint32_t rdlen = adapter->rx_ring.count * sizeof(struct ixgb_rx_desc);
@@ -805,9 +780,9 @@ static void ixgb_configure_rx(struct ixg
 	IXGB_WRITE_REG(hw, RDT, 0);
 
 	/* burst 16 or burst when RXT0 */
-	rxdctl = RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT
-	    | RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT
-	    | RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
+	rxdctl =  RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT 
+			| RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT 
+			| RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
 	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
 
 	if (adapter->raidc) {
@@ -821,34 +797,35 @@ static void ixgb_configure_rx(struct ixg
 		 * min is 0 */
 
 		/* polling times are 1 == 0.8192us
-		   2 == 1.6384us
-		   3 == 3.2768us etc
-		   ...
-		   511 == 418 us
+			2 == 1.6384us
+			3 == 3.2768us etc
+			...
+			511 == 418 us
 		 */
-#define IXGB_RAIDC_POLL_DEFAULT 122	/* set to poll every ~100 us under load 
-					   also known as 10000 interrupts / sec */
+#define IXGB_RAIDC_POLL_DEFAULT 122 /* set to poll every ~100 us under load 
+					   also known as 10000 interrupts / sec */
 
 		/* divide this by 2^3 (8) to get a register size count */
-		poll_threshold = ((adapter->rx_ring.count - 1) >> 3);
+		poll_threshold = ((adapter->rx_ring.count-1) >> 3);
 		/* poll at half of that size */
 		poll_threshold >>= 1;
 		/* make sure its not bigger than our max */
 		poll_threshold &= 0x3F;
 
-		raidc = IXGB_RAIDC_EN |	/* turn on raidc style moderation */
-		    IXGB_RAIDC_RXT_GATE |	/* don't interrupt with rxt0 while
-						   in RBD mode (polling) */
-		    (IXGB_RAIDC_POLL_DEFAULT << IXGB_RAIDC_POLL_SHIFT) |
-		    /* this sets the regular "min interrupt delay" */
-		    (adapter->rx_int_delay << IXGB_RAIDC_DELAY_SHIFT) |
-		    poll_threshold;
+		raidc =
+			IXGB_RAIDC_EN | /* turn on raidc style moderation */
+			IXGB_RAIDC_RXT_GATE | /* don't interrupt with rxt0 while
+						 in RBD mode (polling) */
+			(IXGB_RAIDC_POLL_DEFAULT << IXGB_RAIDC_POLL_SHIFT) | 
+			  /* this sets the regular "min interrupt delay" */
+			(adapter-> rx_int_delay << IXGB_RAIDC_DELAY_SHIFT) |
+			poll_threshold;
 
 		IXGB_WRITE_REG(hw, RAIDC, raidc);
 	}
 
 	/* Enable Receive Checksum Offload for TCP and UDP */
-	if (adapter->rx_csum == TRUE) {
+	if(adapter->rx_csum == TRUE) {
 		rxcsum = IXGB_READ_REG(hw, RXCSUM);
 		rxcsum |= IXGB_RXCSUM_TUOFL;
 		IXGB_WRITE_REG(hw, RXCSUM, rxcsum);
@@ -877,7 +844,7 @@ static void ixgb_configure_rx(struct ixg
 	adapter->tx_ring.buffer_info = NULL;
 
 	pci_free_consistent(pdev, adapter->tx_ring.size,
-			    adapter->tx_ring.desc, adapter->tx_ring.dma);
+				adapter->tx_ring.desc, adapter->tx_ring.dma);
 
 	adapter->tx_ring.desc = NULL;
 }
@@ -887,7 +903,8 @@ static void ixgb_free_tx_resources(struc
  * @adapter: board private structure
  **/
 
-static void ixgb_clean_tx_ring(struct ixgb_adapter *adapter)
+static void
+ixgb_clean_tx_ring(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_buffer *buffer_info;
@@ -897,13 +914,14 @@ static void ixgb_clean_tx_ring(struct ix
 
 	/* Free all the Tx ring sk_buffs */
 
-	for (i = 0; i < tx_ring->count; i++) {
+	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		if (buffer_info->skb) {
+		if(buffer_info->skb) {
 
 			pci_unmap_page(pdev,
-				       buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
+					   buffer_info->dma,
+					   buffer_info->length,
+					   PCI_DMA_TODEVICE);
 
 			dev_kfree_skb(buffer_info->skb);
 
@@ -953,7 +971,8 @@ static void ixgb_free_rx_resources(struc
  * @adapter: board private structure
  **/
 
-static void ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
+static void
+ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct ixgb_buffer *buffer_info;
@@ -963,9 +939,9 @@ static void ixgb_clean_rx_ring(struct ix
 
 	/* Free all the Rx ring sk_buffs */
 
-	for (i = 0; i < rx_ring->count; i++) {
+	for(i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if (buffer_info->skb) {
+		if(buffer_info->skb) {
 
 			pci_unmap_single(pdev,
 					 buffer_info->dma,
@@ -1000,12 +1019,13 @@ static void ixgb_clean_rx_ring(struct ix
  * Returns 0 on success, negative on failure
  **/
 
-static int ixgb_set_mac(struct net_device *netdev, void *p)
+static int
+ixgb_set_mac(struct net_device *netdev, void *p)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	struct sockaddr *addr = p;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if(!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
@@ -1025,7 +1045,8 @@ static int ixgb_set_mac(struct net_devic
  * promiscuous mode, and all-multi behavior.
  **/
 
-static void ixgb_set_multi(struct net_device *netdev)
+static void
+ixgb_set_multi(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
@@ -1037,16 +1058,16 @@ static void ixgb_set_multi(struct net_de
 
 	rctl = IXGB_READ_REG(hw, RCTL);
 
-	if (netdev->flags & IFF_PROMISC) {
+	if(netdev->flags & IFF_PROMISC) {
 		rctl |= (IXGB_RCTL_UPE | IXGB_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
+	} else if(netdev->flags & IFF_ALLMULTI) {
 		rctl |= IXGB_RCTL_MPE;
 		rctl &= ~IXGB_RCTL_UPE;
 	} else {
 		rctl &= ~(IXGB_RCTL_UPE | IXGB_RCTL_MPE);
 	}
 
-	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
+	if(netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
@@ -1054,10 +1075,10 @@ static void ixgb_set_multi(struct net_de
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
-		for (i = 0, mc_ptr = netdev->mc_list; mc_ptr;
-		     i++, mc_ptr = mc_ptr->next)
+		for(i = 0, mc_ptr = netdev->mc_list; mc_ptr;
+			i++, mc_ptr = mc_ptr->next)
 			memcpy(&mta[i * IXGB_ETH_LENGTH_OF_ADDRESS],
-			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
+				   mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
 		ixgb_mc_addr_list_update(hw, mta, netdev->mc_count, 0);
 	}
@@ -1068,7 +1043,8 @@ static void ixgb_set_multi(struct net_de
  * @data: pointer to netdev cast into an unsigned long
  **/
 
-static void ixgb_watchdog(unsigned long data)
+static void
+ixgb_watchdog(unsigned long data)
 {
 	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
 	struct net_device *netdev = adapter->netdev;
@@ -1082,10 +1057,10 @@ static void ixgb_watchdog(unsigned long 
 		netif_stop_queue(netdev);
 	}
 
-	if (adapter->hw.link_up) {
-		if (!netif_carrier_ok(netdev)) {
+	if(adapter->hw.link_up) {
+		if(!netif_carrier_ok(netdev)) {
 			printk(KERN_INFO "ixgb: %s NIC Link is Up %d Mbps %s\n",
-			       netdev->name, 10000, "Full Duplex");
+				   netdev->name, 10000, "Full Duplex");
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
 			netif_carrier_on(netdev);
@@ -1092,11 +1057,12 @@ 
 			netif_wake_queue(netdev);
 		}
 	} else {
-		if (netif_carrier_ok(netdev)) {
+		if(netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
 			printk(KERN_INFO
-			       "ixgb: %s NIC Link is Down\n", netdev->name);
+				   "ixgb: %s NIC Link is Down\n",
+				   netdev->name);
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 
@@ -1105,8 +1128,8 @@ static void ixgb_watchdog(unsigned long 
 
 	ixgb_update_stats(adapter);
 
-	if (!netif_carrier_ok(netdev)) {
-		if (IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
+	if(!netif_carrier_ok(netdev)) {
+		if(IXGB_DESC_UNUSED(txdr) + 1 < txdr->count) {
 			/* We've lost link, so the controller stops DMA,
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
@@ -1117,13 +1140,13 @@ static void ixgb_watchdog(unsigned long 
 
 	/* Early detection of hung controller */
 	i = txdr->next_to_clean;
-	if (txdr->buffer_info[i].dma &&
-	    time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
-	    !(IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_TXOFF))
+	if(txdr->buffer_info[i].dma &&
+	   time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
+	   !(IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_TXOFF))
 		netif_stop_queue(netdev);
 
 	/* generate an interrupt to force clean up of any stragglers */
-	IXGB_WRITE_REG(&adapter->hw, ICS, IXGB_INT_TXDW);
+	IXGB_WRITE_REG (&adapter->hw, ICS, IXGB_INT_TXDW);
 
 	/* Reset the timer */
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
@@ -1142,14 +1165,16 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
 	uint16_t ipcse, tucse, mss;
 
-	if (likely(skb_shinfo(skb)->tso_size)) {
+	if(likely(skb_shinfo(skb)->tso_size)) {
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
 		skb->nh.iph->tot_len = 0;
 		skb->nh.iph->check = 0;
 		skb->h.th->check = ~csum_tcpudp_magic(skb->nh.iph->saddr,
-						      skb->nh.iph->daddr,
-						      0, IPPROTO_TCP, 0);
+						  skb->nh.iph->daddr,
+						  0,
+						  IPPROTO_TCP,
+						  0);
 		ipcss = skb->nh.raw - skb->data;
 		ipcso = (void *)&(skb->nh.iph->check) - (void *)skb->data;
 		ipcse = skb->h.raw - skb->data - 1;
@@ -1159,32 +1184,26 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 
 		i = adapter->tx_ring.next_to_use;
 		context_desc = IXGB_CONTEXT_DESC(adapter->tx_ring, i);
-
-		context_desc->ipcss = ipcss;
-		context_desc->ipcso = ipcso;
-		context_desc->ipcse = cpu_to_le16(ipcse);
-		context_desc->tucss = tucss;
-		context_desc->tucso = tucso;
-		context_desc->tucse = cpu_to_le16(tucse);
-		context_desc->mss = cpu_to_le16(mss);
-		context_desc->hdr_len = hdr_len;
+		
+		context_desc->ipcss  = ipcss;
+		context_desc->ipcso  = ipcso;
+		context_desc->ipcse  = cpu_to_le16(ipcse);
+		context_desc->tucss  = tucss;
+		context_desc->tucso  = tucso;
+		context_desc->tucse  = cpu_to_le16(tucse);
+		context_desc->mss    = cpu_to_le16(mss);
+		context_desc->hdr_len= hdr_len;
 		context_desc->status = 0;
-		context_desc->cmd_type_len = cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
-							 |
-							 IXGB_CONTEXT_DESC_CMD_TSE
-							 |
-							 IXGB_CONTEXT_DESC_CMD_IP
-							 |
-							 IXGB_CONTEXT_DESC_CMD_TCP
-							 |
-							 IXGB_CONTEXT_DESC_CMD_RS
-							 |
-							 IXGB_CONTEXT_DESC_CMD_IDE
-							 | (skb->len -
-							    (hdr_len)));
+		context_desc->cmd_type_len = cpu_to_le32(
+						  IXGB_CONTEXT_DESC_TYPE 
+						| IXGB_CONTEXT_DESC_CMD_TSE
+						| IXGB_CONTEXT_DESC_CMD_IP
+						| IXGB_CONTEXT_DESC_CMD_TCP
+						| IXGB_CONTEXT_DESC_CMD_RS
+						| IXGB_CONTEXT_DESC_CMD_IDE
+						| (skb->len - (hdr_len)));
 
-		if (++i == adapter->tx_ring.count)
-			i = 0;
+		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
 		return TRUE;
@@ -1201,7 +1177,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 	unsigned int i;
 	uint8_t css, cso;
 
-	if (likely(skb->ip_summed == CHECKSUM_HW)) {
+	if(likely(skb->ip_summed == CHECKSUM_HW)) {
 		css = skb->h.raw - skb->data;
 		cso = (skb->h.raw + skb->csum) - skb->data;
 
@@ -1212,16 +1188,16 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 		context_desc->tucso = cso;
 		context_desc->tucse = 0;
 		/* zero out any previously existing data in one instruction */
-		*(uint32_t *) & (context_desc->ipcss) = 0;
+		*(uint32_t *)&(context_desc->ipcss) = 0;
 		context_desc->status = 0;
 		context_desc->hdr_len = 0;
 		context_desc->mss = 0;
 		context_desc->cmd_type_len =
-		    cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
-				| IXGB_TX_DESC_CMD_RS | IXGB_TX_DESC_CMD_IDE);
+			cpu_to_le32(IXGB_CONTEXT_DESC_TYPE
+					| IXGB_TX_DESC_CMD_RS 
+					| IXGB_TX_DESC_CMD_IDE);
 
-		if (++i == adapter->tx_ring.count)
-			i = 0;
+		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
 		return TRUE;
@@ -1235,7 +1211,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapte
 
 static inline int
 ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
-	    unsigned int first)
+		unsigned int first)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_buffer *buffer_info;
@@ -1248,23 +1224,24 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 
 	i = tx_ring->next_to_use;
 
-	while (len) {
+	while(len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
 		buffer_info->length = size;
 		buffer_info->dma =
-		    pci_map_single(adapter->pdev,
-				   skb->data + offset, size, PCI_DMA_TODEVICE);
+			pci_map_single(adapter->pdev,
+				skb->data + offset,
+				size,
+				PCI_DMA_TODEVICE);
 		buffer_info->time_stamp = jiffies;
 
 		len -= size;
 		offset += size;
 		count++;
-		if (++i == tx_ring->count)
-			i = 0;
+		if(++i == tx_ring->count) i = 0;
 	}
 
-	for (f = 0; f < nr_frags; f++) {
+	for(f = 0; f < nr_frags; f++) {
 		struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
@@ -1271,22 +1224,22 @@ 
 		len = frag->size;
 		offset = 0;
 
-		while (len) {
+		while(len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_JUMBO_FRAME_SIZE);
 			buffer_info->length = size;
 			buffer_info->dma =
-			    pci_map_page(adapter->pdev,
-					 frag->page,
-					 frag->page_offset + offset,
-					 size, PCI_DMA_TODEVICE);
+				pci_map_page(adapter->pdev,
+					frag->page,
+					frag->page_offset + offset,
+					size,
+					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp = jiffies;
 
 			len -= size;
 			offset += size;
 			count++;
-			if (++i == tx_ring->count)
-				i = 0;
+			if(++i == tx_ring->count) i = 0;
 		}
 	}
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
@@ -1297,8 +1273,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 }
 
 static inline void
-ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,
-	      int tx_flags)
+ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_tx_desc *tx_desc = NULL;
@@ -1308,36 +1284,35 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 	uint8_t popts = 0;
 	unsigned int i;
 
-	if (tx_flags & IXGB_TX_FLAGS_TSO) {
+	if(tx_flags & IXGB_TX_FLAGS_TSO) {
 		cmd_type_len |= IXGB_TX_DESC_CMD_TSE;
 		popts |= (IXGB_TX_DESC_POPTS_IXSM | IXGB_TX_DESC_POPTS_TXSM);
 	}
 
-	if (tx_flags & IXGB_TX_FLAGS_CSUM)
+	if(tx_flags & IXGB_TX_FLAGS_CSUM)
 		popts |= IXGB_TX_DESC_POPTS_TXSM;
 
-	if (tx_flags & IXGB_TX_FLAGS_VLAN) {
+	if(tx_flags & IXGB_TX_FLAGS_VLAN) {
 		cmd_type_len |= IXGB_TX_DESC_CMD_VLE;
 	}
 
 	i = tx_ring->next_to_use;
 
-	while (count--) {
+	while(count--) {
 		buffer_info = &tx_ring->buffer_info[i];
 		tx_desc = IXGB_TX_DESC(*tx_ring, i);
 		tx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 		tx_desc->cmd_type_len =
-		    cpu_to_le32(cmd_type_len | buffer_info->length);
+			cpu_to_le32(cmd_type_len | buffer_info->length);
 		tx_desc->status = status;
 		tx_desc->popts = popts;
 		tx_desc->vlan = cpu_to_le16(vlan_id);
 
-		if (++i == tx_ring->count)
-			i = 0;
+		if(++i == tx_ring->count) i = 0;
 	}
 
-	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP
-					     | IXGB_TX_DESC_CMD_RS);
+	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP 
+				| IXGB_TX_DESC_CMD_RS );
 
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -1355,7 +1331,8 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 #define DESC_NEEDED TXD_USE_COUNT(IXGB_MAX_DATA_PER_TXD) + \
 	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1
 
-static int ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static int
+ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	unsigned int first;
@@ -1363,13 +1339,13 @@ static int ixgb_xmit_frame(struct sk_buf
 	unsigned long flags;
 	int vlan_id = 0;
 
-	if (skb->len <= 0) {
+	if(skb->len <= 0) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
 	spin_lock_irqsave(&adapter->tx_lock, flags);
-	if (unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
+	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
@@ -1376,20 +1339,20 @@ 
 	}
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
 		vlan_id = vlan_tx_tag_get(skb);
 	}
 
 	first = adapter->tx_ring.next_to_use;
-
-	if (ixgb_tso(adapter, skb))
+	
+	if(ixgb_tso(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_TSO;
-	else if (ixgb_tx_csum(adapter, skb))
+	else if(ixgb_tx_csum(adapter, skb))
 		tx_flags |= IXGB_TX_FLAGS_CSUM;
 
 	ixgb_tx_queue(adapter, ixgb_tx_map(adapter, skb, first), vlan_id,
-		      tx_flags);
+			tx_flags);
 
 	netdev->trans_start = jiffies;
 
@@ -1401,7 +1377,8 @@ static int ixgb_xmit_frame(struct sk_buf
  * @netdev: network interface device structure
  **/
 
-static void ixgb_tx_timeout(struct net_device *netdev)
+static void
+ixgb_tx_timeout(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
@@ -1409,7 +1385,8 @@ static void ixgb_tx_timeout(struct net_d
 	schedule_work(&adapter->tx_timeout_task);
 }
 
-static void ixgb_tx_timeout_task(struct net_device *netdev)
+static void
+ixgb_tx_timeout_task(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
@@ -1425,7 +1403,8 @@ static void ixgb_tx_timeout_task(struct 
  * The statistics are actually updated from the timer callback.
  **/
 
-static struct net_device_stats *ixgb_get_stats(struct net_device *netdev)
+static struct net_device_stats *
+ixgb_get_stats(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
@@ -1440,27 +1418,27 @@ static struct net_device_stats *ixgb_get
  * Returns 0 on success, negative on failure
  **/
 
-static int ixgb_change_mtu(struct net_device *netdev, int new_mtu)
+static int
+ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 	int old_max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 
-	if ((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
-	    || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
+	if((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
+	   || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
 		IXGB_ERR("Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
-	if ((max_frame <=
-	     IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
-	    || (max_frame <= IXGB_RXBUFFER_2048)) {
+	if((max_frame <= IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
+	   || (max_frame <= IXGB_RXBUFFER_2048)) {
 		adapter->rx_buffer_len = IXGB_RXBUFFER_2048;
 
-	} else if (max_frame <= IXGB_RXBUFFER_4096) {
+	} else if(max_frame <= IXGB_RXBUFFER_4096) {
 		adapter->rx_buffer_len = IXGB_RXBUFFER_4096;
 
-	} else if (max_frame <= IXGB_RXBUFFER_8192) {
+	} else if(max_frame <= IXGB_RXBUFFER_8192) {
 		adapter->rx_buffer_len = IXGB_RXBUFFER_8192;
 
 	} else {
@@ -1593,28 +1600,29 @@ static void ixgb_update_stats(struct ixg
  * @pt_regs: CPU registers structure
  **/
 
-static irqreturn_t ixgb_intr(int irq, void *data, struct pt_regs *regs)
+static irqreturn_t
+ixgb_intr(int irq, void *data, struct pt_regs *regs)
 {
 	struct net_device *netdev = data;
 	struct ixgb_adapter *adapter = netdev->priv;
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t icr = IXGB_READ_REG(&adapter->hw, ICR);
+	uint32_t icr = IXGB_READ_REG(hw, ICR);
 #ifndef CONFIG_IXGB_NAPI
 	unsigned int i;
 #endif
 
-	if (unlikely(!icr))
-		return IRQ_NONE;	/* Not our interrupt */
+	if(unlikely(!icr))
+		return IRQ_NONE;  /* Not our interrupt */
 
-	if (unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC))) {
+	if(unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC))) {
 		mod_timer(&adapter->watchdog_timer, jiffies);
 	}
 #ifdef CONFIG_IXGB_NAPI
-	if (netif_rx_schedule_prep(netdev)) {
+	if(netif_rx_schedule_prep(netdev)) {
 
 		/* Disable interrupts and register for poll. The flush 
-		   of the posted write is intentionally left out.
-		 */
+		  of the posted write is intentionally left out.
+		*/
 
 		atomic_inc(&adapter->irq_sem);
 		IXGB_WRITE_REG(hw, IMC, ~0);
@@ -1647,7 +1652,8 @@ static irqreturn_t ixgb_intr(int irq, vo
  * @adapter: board private structure
  **/
 
-static int ixgb_clean(struct net_device *netdev, int *budget)
+static int
+ixgb_clean(struct net_device *netdev, int *budget)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	int work_to_do = min(*budget, netdev->quota);
@@ -1678,7 +1702,8 @@ static int ixgb_clean(struct net_device 
  * @adapter: board private structure
  **/
 
-static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
+static boolean_t
+ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct net_device *netdev = adapter->netdev;
@@ -1692,9 +1693,9 @@ static boolean_t ixgb_clean_tx_irq(struc
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = IXGB_TX_DESC(*tx_ring, eop);
 
-	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
+	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
-		for (cleaned = FALSE; !cleaned;) {
+		for(cleaned = FALSE; !cleaned; ) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
@@ -1703,17 +1693,17 @@ 
 			       IXGB_TX_DESC_POPTS_IXSM))
 				adapter->hw_csum_tx_good++;
 
-			if (buffer_info->dma) {
+			if(buffer_info->dma) {
 
 				pci_unmap_page(pdev,
-					       buffer_info->dma,
-					       buffer_info->length,
-					       PCI_DMA_TODEVICE);
+						   buffer_info->dma,
+						   buffer_info->length,
+						   PCI_DMA_TODEVICE);
 
 				buffer_info->dma = 0;
 			}
 
-			if (buffer_info->skb) {
+			if(buffer_info->skb) {
 
 				dev_kfree_skb_any(buffer_info->skb);
 
@@ -1720,13 +1693,12 @@ 
 				buffer_info->skb = NULL;
 			}
 
-			*(uint32_t *) & (tx_desc->status) = 0;
+			*(uint32_t *)&(tx_desc->status) = 0;
 
 			cleaned = (i == eop);
-			if (++i == tx_ring->count)
-				i = 0;
+			if(++i == tx_ring->count) i = 0;
 		}
-
+		
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = IXGB_TX_DESC(*tx_ring, eop);
 	}
@@ -1734,8 +1758,8 @@ static boolean_t ixgb_clean_tx_irq(struc
 	tx_ring->next_to_clean = i;
 
 	spin_lock(&adapter->tx_lock);
-	if (cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev)
-	    && (IXGB_DESC_UNUSED(tx_ring) > IXGB_TX_QUEUE_WAKE)) {
+	if(cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev) &&
+	   (IXGB_DESC_UNUSED(tx_ring) > IXGB_TX_QUEUE_WAKE)) {
 
 		netif_wake_queue(netdev);
 	}
@@ -1784,7 +1745,8 @@ static boolean_t ixgb_clean_tx_irq(struc
 
 static boolean_t
 #ifdef CONFIG_IXGB_NAPI
-ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
+ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done,
+				   int work_to_do)
 #else
 ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 #endif
@@ -1803,7 +1770,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 	rx_desc = IXGB_RX_DESC(*rx_ring, i);
 	buffer_info = &rx_ring->buffer_info[i];
 
-	while (rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
+	while(rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
 #ifdef CONFIG_IXGB_NAPI
 		if(*work_done >= work_to_do)
 			break;
@@ -1813,13 +1770,11 @@ 
 		skb = buffer_info->skb;
 		prefetch(skb->data);
 
-		if (++i == rx_ring->count)
-			i = 0;
+		if(++i == rx_ring->count) i = 0;
 		next_rxd = IXGB_RX_DESC(*rx_ring, i);
 		prefetch(next_rxd);
 
-		if ((j = i + 1) == rx_ring->count)
-			j = 0;
+		if((j = i + 1) == rx_ring->count) j = 0;
 		next2_buffer = &rx_ring->buffer_info[j];
 		prefetch(next2_buffer);
 
@@ -1831,17 +1790,18 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 		cleaned = TRUE;
 
 		pci_unmap_single(pdev,
-				 buffer_info->dma,
-				 buffer_info->length, PCI_DMA_FROMDEVICE);
+						 buffer_info->dma,
+						 buffer_info->length,
+						 PCI_DMA_FROMDEVICE);
 
 		length = le16_to_cpu(rx_desc->length);
 
-		if (unlikely(!(rx_desc->status & IXGB_RX_DESC_STATUS_EOP))) {
+		if(unlikely(!(rx_desc->status & IXGB_RX_DESC_STATUS_EOP))) {
 
 			/* All receives must fit into a single buffer */
 
 			IXGB_DBG("Receive packet consumed multiple buffers "
-				 "length<%x>\n", length);
+					 "length<%x>\n", length);
 
 			dev_kfree_skb_irq(skb);
 			rx_desc->status = 0;
@@ -1852,10 +1876,10 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 			continue;
 		}
 
-		if (unlikely(rx_desc->errors
-			     & (IXGB_RX_DESC_ERRORS_CE | IXGB_RX_DESC_ERRORS_SE
-				| IXGB_RX_DESC_ERRORS_P |
-				IXGB_RX_DESC_ERRORS_RXE))) {
+		if(unlikely(rx_desc->errors 
+			& (IXGB_RX_DESC_ERRORS_CE | IXGB_RX_DESC_ERRORS_SE |
+			   IXGB_RX_DESC_ERRORS_P | IXGB_RX_DESC_ERRORS_RXE))) {
+
 
 			dev_kfree_skb_irq(skb);
 			rx_desc->status = 0;
@@ -1891,7 +1836,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 		} else {
 			netif_rx(skb);
 		}
-#endif				/* CONFIG_IXGB_NAPI */
+#endif /* CONFIG_IXGB_NAPI */
 		netdev->last_rx = jiffies;
 
 		rx_desc->status = 0;
@@ -1913,7 +1937,8 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
  * @adapter: address of board private structure
  **/
 
-static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
+static void
+ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct net_device *netdev = adapter->netdev;
@@ -1927,21 +1952,22 @@ static void ixgb_alloc_rx_buffers(struct
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
-	cleancount = IXGB_DESC_UNUSED(rx_ring);
+	cleancount = IXGB_DESC_UNUSED (rx_ring);
 
 	/* lessen this to 4 if we're
 	 * in the midst of raidc and rbd is occuring
 	 * because we don't want to delay returning buffers when low
 	 */
-	num_group_tail_writes = adapter->raidc ? 4 : IXGB_RX_BUFFER_WRITE;
-
+	num_group_tail_writes 
+		= adapter->raidc ? 4 : IXGB_RX_BUFFER_WRITE;
+	
 	/* leave one descriptor unused */
-	while (--cleancount > 0) {
+	while(--cleancount > 0) {
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 
 		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
 
-		if (unlikely(!skb)) {
+		if(unlikely(!skb)) {
 			/* Better luck next round */
 			break;
 		}
@@ -1957,13 +1983,14 @@ static void ixgb_alloc_rx_buffers(struct
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 		buffer_info->dma =
-		    pci_map_single(pdev,
-				   skb->data,
-				   adapter->rx_buffer_len, PCI_DMA_FROMDEVICE);
+			pci_map_single(pdev,
+					   skb->data,
+					   adapter->rx_buffer_len,
+					   PCI_DMA_FROMDEVICE);
 
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 
-		if ((i & ~(num_group_tail_writes - 1)) == i) {
+		if((i & ~(num_group_tail_writes- 1)) == i) {
 			/* Force memory writes to complete before letting h/w
 			 * know there are new descriptors to fetch.  (Only
 			 * applicable for weak-ordered memory model archs,
@@ -1973,8 +2000,7 @@ static void ixgb_alloc_rx_buffers(struct
 			IXGB_WRITE_REG(&adapter->hw, RDT, i);
 		}
 
-		if (++i == rx_ring->count)
-			i = 0;
+		if(++i == rx_ring->count) i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
@@ -1996,7 +2022,7 @@ ixgb_vlan_rx_register(struct net_device 
 	ixgb_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
-	if (grp) {
+	if(grp) {
 		/* enable VLAN tag insert/strip */
 		ctrl = IXGB_READ_REG(&adapter->hw, CTRL0);
 		ctrl |= IXGB_CTRL0_VME;
@@ -2025,7 +2051,8 @@ ixgb_vlan_rx_register(struct net_device 
 	ixgb_irq_enable(adapter);
 }
 
-static void ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
+static void
+ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	uint32_t vfta, index;
@@ -2038,7 +2064,8 @@ static void ixgb_vlan_rx_add_vid(struct 
 	ixgb_write_vfta(&adapter->hw, index, vfta);
 }
 
-static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
+static void
+ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 	uint32_t vfta, index;
@@ -2045,7 +2064,7 @@ 
 
 	ixgb_irq_disable(adapter);
 
-	if (adapter->vlgrp)
+	if(adapter->vlgrp)
 		adapter->vlgrp->vlan_devices[vid] = NULL;
 
 	ixgb_irq_enable(adapter);
@@ -2058,14 +2084,15 @@ static void ixgb_vlan_rx_kill_vid(struct
 	ixgb_write_vfta(&adapter->hw, index, vfta);
 }
 
-static void ixgb_restore_vlan(struct ixgb_adapter *adapter)
+static void
+ixgb_restore_vlan(struct ixgb_adapter *adapter)
 {
 	ixgb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
-	if (adapter->vlgrp) {
+	if(adapter->vlgrp) {
 		uint16_t vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
-			if (!adapter->vlgrp->vlan_devices[vid])
+		for(vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+			if(!adapter->vlgrp->vlan_devices[vid])
 				continue;
 			ixgb_vlan_rx_add_vid(adapter->netdev, vid);
 		}
@@ -2083,12 +2111,12 @@ ixgb_notify_reboot(struct notifier_block
 {
 	struct pci_dev *pdev = NULL;
 
-	switch (event) {
+	switch(event) {
 	case SYS_DOWN:
 	case SYS_HALT:
 	case SYS_POWER_OFF:
-		while ((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
-			if (pci_dev_driver(pdev) == &ixgb_driver)
+		while((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
+			if(pci_dev_driver(pdev) == &ixgb_driver)
 				ixgb_suspend(pdev, 3);
 		}
 	}
@@ -2100,7 +2111,8 @@ 
  * @param pdev pci driver structure used for passing to
  * @param state power state to enter 
  **/
-static int ixgb_suspend(struct pci_dev *pdev, uint32_t state)
+static int
+ixgb_suspend(struct pci_dev *pdev, uint32_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev->priv;
@@ -2107,7 +2111,7 @@ 
 
 	netif_device_detach(netdev);
 
-	if (netif_running(netdev))
+	if(netif_running(netdev))
 		ixgb_down(adapter, TRUE);
 
 	pci_save_state(pdev, adapter->pci_state);
diff -up netdev-2.6/drivers/net/ixgb/ixgb_osdep.h netdev-2.6/drivers/net/ixgb.new/ixgb_osdep.h
--- netdev-2.6/drivers/net/ixgb/ixgb_osdep.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_osdep.h	2004-10-15 13:15:56.000000000 -0700
@@ -77,20 +77,21 @@ typedef enum {
 #define DEBUGOUT3 DEBUGOUT2
 #define DEBUGOUT7 DEBUGOUT3
 
+
 #define IXGB_WRITE_REG(a, reg, value) ( \
-    writel((value), ((a)->hw_addr + IXGB_##reg)))
+	writel((value), ((a)->hw_addr + IXGB_##reg)))
 
 #define IXGB_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + IXGB_##reg))
+	readl((a)->hw_addr + IXGB_##reg))
 
 #define IXGB_WRITE_REG_ARRAY(a, reg, offset, value) ( \
-    writel((value), ((a)->hw_addr + IXGB_##reg + ((offset) << 2))))
+	writel((value), ((a)->hw_addr + IXGB_##reg + ((offset) << 2))))
 
 #define IXGB_READ_REG_ARRAY(a, reg, offset) ( \
-    readl((a)->hw_addr + IXGB_##reg + ((offset) << 2)))
+	readl((a)->hw_addr + IXGB_##reg + ((offset) << 2)))
 
 #define IXGB_WRITE_FLUSH(a) IXGB_READ_REG(a, STATUS)
 
 #define IXGB_MEMCPY memcpy
 
-#endif				/* _IXGB_OSDEP_H_ */
+#endif /* _IXGB_OSDEP_H_ */
diff -up netdev-2.6/drivers/net/ixgb/ixgb_param.c netdev-2.6/drivers/net/ixgb.new/ixgb_param.c
--- netdev-2.6/drivers/net/ixgb/ixgb_param.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_param.c	2004-10-15 13:15:57.000000000 -0700
@@ -34,7 +34,7 @@
 
 #define IXGB_MAX_NIC 8
 
-#define OPTION_UNSET    -1
+#define OPTION_UNSET	-1
 #define OPTION_DISABLED 0
 #define OPTION_ENABLED  1
 
@@ -188,38 +188,37 @@ IXGB_PARAM(IntDelayEnable, "Transmit Int
 #define FLOW_CONTROL_DEFAULT  FLOW_CONTROL_FULL
 #define DEFAULT_FCRTL	  		0x28000
 #define DEFAULT_FCRTH			0x30000
-#define MIN_FCRTL			      0
+#define MIN_FCRTL			0
 #define MAX_FCRTL			0x3FFE8
-#define MIN_FCRTH			      8
+#define MIN_FCRTH			8
 #define MAX_FCRTH			0x3FFF0
 
-#define DEFAULT_FCPAUSE		  	0x100	/* this may be too long */
-#define MIN_FCPAUSE			      1
+#define DEFAULT_FCPAUSE		0x100 /* this may be too long */
+#define MIN_FCPAUSE			1
 #define MAX_FCPAUSE			 0xffff
 
+
 struct ixgb_option {
 	enum { enable_option, range_option, list_option } type;
 	char *name;
 	char *err;
-	int def;
+	int  def;
 	union {
-		struct {	/* range_option info */
+		struct { /* range_option info */
 			int min;
 			int max;
 		} r;
-		struct {	/* list_option info */
+		struct { /* list_option info */
 			int nr;
-			struct ixgb_opt_list {
-				int i;
-				char *str;
-			} *p;
+			struct ixgb_opt_list { int i; char *str; } *p;
 		} l;
 	} arg;
 };
 
-static int __devinit ixgb_validate_option(int *value, struct ixgb_option *opt)
+static int __devinit
+ixgb_validate_option(int *value, struct ixgb_option *opt)
 {
-	if (*value == OPTION_UNSET) {
+	if(*value == OPTION_UNSET) {
 		*value = opt->def;
 		return 0;
 	}
@@ -236,32 +235,31 @@ static int __devinit ixgb_validate_optio
 		}
 		break;
 	case range_option:
-		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
+		if(*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
 			printk(KERN_INFO "%s set to %i\n", opt->name, *value);
 			return 0;
 		}
 		break;
-	case list_option:{
-			int i;
-			struct ixgb_opt_list *ent;
-
-			for (i = 0; i < opt->arg.l.nr; i++) {
-				ent = &opt->arg.l.p[i];
-				if (*value == ent->i) {
-					if (ent->str[0] != '\0')
-						printk(KERN_INFO "%s\n",
-						       ent->str);
-					return 0;
-				}
+	case list_option: {
+		int i;
+		struct ixgb_opt_list *ent;
+
+		for(i = 0; i < opt->arg.l.nr; i++) {
+			ent = &opt->arg.l.p[i];
+			if(*value == ent->i) {
+				if(ent->str[0] != '\0')
+					printk(KERN_INFO "%s\n", ent->str);
+				return 0;
 			}
 		}
+	}
 		break;
 	default:
 		BUG();
 	}
 
 	printk(KERN_INFO "Invalid %s specified (%i) %s\n",
-	       opt->name, *value, opt->err);
+		   opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -278,24 +276,25 @@ static int __devinit ixgb_validate_optio
  * in a variable in the adapter structure.
  **/
 
-void __devinit ixgb_check_options(struct ixgb_adapter *adapter)
+void __devinit
+ixgb_check_options(struct ixgb_adapter *adapter)
 {
 	int bd = adapter->bd_number;
-	if (bd >= IXGB_MAX_NIC) {
+	if(bd >= IXGB_MAX_NIC) {
 		printk(KERN_NOTICE
-		       "Warning: no configuration for board #%i\n", bd);
+			   "Warning: no configuration for board #%i\n", bd);
 		printk(KERN_NOTICE "Using defaults for all values\n");
 		bd = IXGB_MAX_NIC;
 	}
 
-	{			/* Transmit Descriptor Count */
+	{ /* Transmit Descriptor Count */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Descriptors",
-			.err = "using default of " __MODULE_STRING(DEFAULT_TXD),
-			.def = DEFAULT_TXD,
-			.arg = {.r = {.min = MIN_TXD,
-				      .max = MAX_TXD}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_TXD),
+			.def  = DEFAULT_TXD,
+			.arg  = { .r = { .min = MIN_TXD,
+					 .max = MAX_TXD}}
 		};
 		struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 
@@ -303,14 +302,14 @@ void __devinit ixgb_check_options(struct
 		ixgb_validate_option(&tx_ring->count, &opt);
 		IXGB_ROUNDUP(tx_ring->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 	}
-	{			/* Receive Descriptor Count */
+	{ /* Receive Descriptor Count */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Descriptors",
-			.err = "using default of " __MODULE_STRING(DEFAULT_RXD),
-			.def = DEFAULT_RXD,
-			.arg = {.r = {.min = MIN_RXD,
-				      .max = MAX_RXD}}
+			.err  = "using default of " __MODULE_STRING(DEFAULT_RXD),
+			.def  = DEFAULT_RXD,
+			.arg  = { .r = { .min = MIN_RXD,
+					 .max = MAX_RXD}}
 		};
 		struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 
@@ -318,12 +328,12 @@ void __devinit ixgb_check_options(struct
 		ixgb_validate_option(&rx_ring->count, &opt);
 		IXGB_ROUNDUP(rx_ring->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 	}
-	{			/* Receive Checksum Offload Enable */
+	{ /* Receive Checksum Offload Enable */
 		struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Receive Checksum Offload",
-			.err = "defaulting to Enabled",
-			.def = OPTION_ENABLED
+			.err  = "defaulting to Enabled",
+			.def  = OPTION_ENABLED
 		};
 
 		int rx_csum = XsumRX[bd];
@@ -330,23 +328,22 @@ 
 		ixgb_validate_option(&rx_csum, &opt);
 		adapter->rx_csum = rx_csum;
 	}
-	{			/* Flow Control */
+	{ /* Flow Control */
 
 		struct ixgb_opt_list fc_list[] =
-		    { {ixgb_fc_none, "Flow Control Disabled"},
-		{ixgb_fc_rx_pause, "Flow Control Receive Only"},
-		{ixgb_fc_tx_pause, "Flow Control Transmit Only"},
-		{ixgb_fc_full, "Flow Control Enabled"},
-		{ixgb_fc_default, "Flow Control Hardware Default"}
-		};
+			{{ ixgb_fc_none,	"Flow Control Disabled" },
+			 { ixgb_fc_rx_pause,"Flow Control Receive Only" },
+			 { ixgb_fc_tx_pause,"Flow Control Transmit Only" },
+			 { ixgb_fc_full,	"Flow Control Enabled" },
+			 { ixgb_fc_default, "Flow Control Hardware Default" }};
 
 		struct ixgb_option opt = {
 			.type = list_option,
 			.name = "Flow Control",
-			.err = "reading default settings from EEPROM",
-			.def = ixgb_fc_full,
-			.arg = {.l = {.nr = LIST_LEN(fc_list),
-				      .p = fc_list}}
+			.err  = "reading default settings from EEPROM",
+			.def  = ixgb_fc_full,
+			.arg  = { .l = { .nr = LIST_LEN(fc_list),
+					 .p = fc_list }}
 		};
 
 		int fc = FlowControl[bd];
@@ -353,7 +328,7 @@ 
 		ixgb_validate_option(&fc, &opt);
 		adapter->hw.fc.type = fc;
 	}
-	{			/* Receive Flow Control High Threshold */
+	{ /* Receive Flow Control High Threshold */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control High Threshold",
@@ -366,11 +328,11 @@ 
 
 		adapter->hw.fc.high_water = RxFCHighThresh[bd];
 		ixgb_validate_option(&adapter->hw.fc.high_water, &opt);
-		if (!(adapter->hw.fc.type & ixgb_fc_rx_pause))
-			printk(KERN_INFO
-			       "Ignoring RxFCHighThresh when no RxFC\n");
+		if ( !(adapter->hw.fc.type & ixgb_fc_rx_pause) )
+			printk (KERN_INFO 
+				"Ignoring RxFCHighThresh when no RxFC\n");
 	}
-	{			/* Receive Flow Control Low Threshold */
+	{ /* Receive Flow Control Low Threshold */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Rx Flow Control Low Threshold",
@@ -383,11 +328,11 @@ 
 
 		adapter->hw.fc.low_water = RxFCLowThresh[bd];
 		ixgb_validate_option(&adapter->hw.fc.low_water, &opt);
-		if (!(adapter->hw.fc.type & ixgb_fc_rx_pause))
-			printk(KERN_INFO
-			       "Ignoring RxFCLowThresh when no RxFC\n");
+		if ( !(adapter->hw.fc.type & ixgb_fc_rx_pause) )
+			printk (KERN_INFO 
+				"Ignoring RxFCLowThresh when no RxFC\n");
 	}
-	{			/* Flow Control Pause Time Request */
+	{ /* Flow Control Pause Time Request*/
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Flow Control Pause Time Request",
@@ -402,9 +328,9 @@ 
 		int pause_time = FCReqTimeout[bd];
 
 		ixgb_validate_option(&pause_time, &opt);
-		if (!(adapter->hw.fc.type & ixgb_fc_rx_pause))
-			printk(KERN_INFO
-			       "Ignoring FCReqTimeout when no RxFC\n");
+		if ( !(adapter->hw.fc.type & ixgb_fc_rx_pause) )
+			printk (KERN_INFO 
+				"Ignoring FCReqTimeout when no RxFC\n");
 		adapter->hw.fc.pause_time = pause_time;
 	}
 	/* high low and spacing check for rx flow control thresholds */
@@ -412,60 +410,58 @@ void __devinit ixgb_check_options(struct
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */
-			printk(KERN_INFO
-			       "RxFCHighThresh must be >= (RxFCLowThresh + 8), "
-			       "Using Defaults\n");
+			printk (KERN_INFO 
+				"RxFCHighThresh must be >= (RxFCLowThresh + 8), "
+				"Using Defaults\n");
 			adapter->hw.fc.high_water = DEFAULT_FCRTH;
-			adapter->hw.fc.low_water = DEFAULT_FCRTL;
+			adapter->hw.fc.low_water  = DEFAULT_FCRTL;
 		}
 	}
-	{			/* Receive Interrupt Delay */
+	{ /* Receive Interrupt Delay */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_RDTR),
-			.def = DEFAULT_RDTR,
-			.arg = {.r = {.min = MIN_RDTR,
-				      .max = MAX_RDTR}}
+			.err = "using default of " __MODULE_STRING(DEFAULT_RDTR),
+			.def = DEFAULT_RDTR,
+			.arg = { .r = { .min = MIN_RDTR,
+					 .max = MAX_RDTR}}
 		};
 
 		adapter->rx_int_delay = RxIntDelay[bd];
 		ixgb_validate_option(&adapter->rx_int_delay, &opt);
 	}
-	{			/* Receive Interrupt Moderation */
+	{ /* Receive Interrupt Moderation */
 		struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Advanced Receive Interrupt Moderation",
-			.err = "defaulting to Enabled",
-			.def = OPTION_ENABLED
+			.err = "defaulting to Enabled",
+			.def = OPTION_ENABLED
 		};
 		int raidc = RAIDC[bd];
 
 		ixgb_validate_option(&raidc, &opt);
 		adapter->raidc = raidc;
 	}
-	{			/* Transmit Interrupt Delay */
+	{ /* Transmit Interrupt Delay */
 		struct ixgb_option opt = {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
-			.err =
-			    "using default of " __MODULE_STRING(DEFAULT_TIDV),
-			.def = DEFAULT_TIDV,
-			.arg = {.r = {.min = MIN_TIDV,
-				      .max = MAX_TIDV}}
+			.err = "using default of " __MODULE_STRING(DEFAULT_TIDV),
+			.def = DEFAULT_TIDV,
+			.arg = { .r = { .min = MIN_TIDV,
+					 .max = MAX_TIDV}}
 		};
 
 		adapter->tx_int_delay = TxIntDelay[bd];
 		ixgb_validate_option(&adapter->tx_int_delay, &opt);
 	}
 
-	{			/* Transmit Interrupt Delay Enable */
+	{ /* Transmit Interrupt Delay Enable */
 		struct ixgb_option opt = {
 			.type = enable_option,
 			.name = "Tx Interrupt Delay Enable",
-			.err = "defaulting to Enabled",
-			.def = OPTION_ENABLED
+			.err  = "defaulting to Enabled",
+			.def  = OPTION_ENABLED
 		};
 		int ide = IntDelayEnable[bd];
 
